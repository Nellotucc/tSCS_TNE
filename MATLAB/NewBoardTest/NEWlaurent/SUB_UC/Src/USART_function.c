/**
******************************************************************************
* @file       USART_function.c
* @author     Laurent Jenni (EPFL-LSRO)
* @version    V1.1.0
* @date       Feb.2017
* @brief      -
* @verbatim   -
******************************************************************************   
*/
   
#include "USART_function.h"
#include "MISC_function.h"
#include "Channel_function.h"

/*
* The Start frame define what inside the packet
*/
#define TX_FRAME_START                   ((uint8_t)0xFF)

// Liste des entêtes pour les différents type de messages
#define MSG_TYPE_DEBUG                   ((uint8_t)0xFF)                //Message réservé pour le débuggage
#define MSG_TYPE_GET_STATUS              ((uint8_t)0xFE)                //Message utilisé à l'initialisation pour vérifier si le channel fonctionne et pour récuperer son status
#define MSG_TYPE_SET_SINGLE_CHAN_PARAM   ((uint8_t)0xDD)                //Message contenant un seul paramètre du canal (voir "privat_Set_Single_Channel_Param_packet_handler" pour les détails)
#define MSG_TYPE_SET_ALL_CHAN_PARAM      ((uint8_t)0xDC)                //Message contenant tous les paramètres du canal (voir "privat_Set_All_Channel_Param_packet_handler" pour les détails)
#define MSG_TYPE_PULSE_TRIGGER 			 ((uint8_t)0xDB)                //
#define MSG_TYPE_MIN_ID                  ((uint8_t)0xAB)                //Start frame min 
#define MSG_STOP                         ((uint8_t)0x80)                //Stop frame


#define MIN_FRAME_SIZE                    1
#define MAX_FRAME_SIZE                    200
#define RX_BUFFER_SIZE                    256
#define TX_BUFFER_SIZE                    256



/* Possible states for packet reception process   */
typedef enum{ 
  IDLE,                     //Waiting for downstream data frame to start (== 'waiting for FRAME_START')
  DATA_PENDING,        //Waiting for data or 'FRAME_STOP'
}PacketRxStateEnum;
//END typedef


extern DMA_HandleTypeDef      hdma_usart3_rx;
extern UART_HandleTypeDef     huart3;
extern volatile uint32_t      MainStatus;

extern volatile float         HV_PosRailVoltage;
extern volatile float         HV_NegRailVoltage;

static uint8_t                rxDataBuffer[RX_BUFFER_SIZE];
static PacketRxStateEnum      PacketRxState = IDLE;

static uint8_t                txDataBuffer0[TX_BUFFER_SIZE];
static uint8_t                txDataBuffer1[TX_BUFFER_SIZE];
static uint8_t                txBufferCnt     = 0x00;
static uint8_t                txBufferID      = 0x00;



/* Private function prototypes -----------------------------------------------*/
void          privat_Debug_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
void          privat_Status_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
void          privat_Set_All_Channel_Param_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
void          privat_Set_Single_Channel_Param_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
void          privat_Manual_Pulse_Trigger_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);

float         privat_ConvBits2float(uint8_t FloatByteStartID);
uint32_t      privat_ConvBits2uint32(uint8_t Uint32ByteStartID);




/**
  * @brief  Init RX
  * @param  rxData
  * @retval None
  */
void 			USART_rx_init(UART_HandleTypeDef *huart){
	HAL_UART_Receive_DMA(huart, rxDataBuffer, RX_BUFFER_SIZE);
}
//END USART_rx_init

/**
  * @brief  USART channel low level data handling 
	*					Should be called periodicaly to check if there are new datas in "rxDataBuffer" and process them
  * @param  None
  * @retval None, the function call directly '###_packet_handler(..)' to process recieved data/request
  */
void 			USART_rx_handler(void){
	static uint8_t	rxBufferID=0, FrameStartID=0, ByteCounter=0;
	uint8_t 				rxBufferTop,	dataTmp;
	
	rxBufferTop = (uint8_t)(RX_BUFFER_SIZE - hdma_usart3_rx.Instance->CNDTR);

	while(rxBufferID!=rxBufferTop){
		dataTmp = rxDataBuffer[rxBufferID];
		switch(PacketRxState){
			case IDLE: 			//Check if correct starting frame received
					if(dataTmp>=MSG_TYPE_MIN_ID){
						PacketRxState 				=	DATA_PENDING;
						FrameStartID 					= rxBufferID;
						ByteCounter 					= 1;
					}
					break;
			case DATA_PENDING:
					if(dataTmp&(1<<7)){
							if(dataTmp>=MSG_TYPE_MIN_ID){			//Unexpected START FRAME -> ignore previous frame and start from begining
									FrameStartID 					= rxBufferID;
									ByteCounter 					= 1;
							}else if(dataTmp==MSG_STOP){		//Ok -> process recieved data
									if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_DEBUG){
										privat_Debug_packet_handler(FrameStartID, ByteCounter);
									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_GET_STATUS){
										privat_Status_packet_handler(FrameStartID, ByteCounter);										
									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_ALL_CHAN_PARAM){
										privat_Set_All_Channel_Param_packet_handler(FrameStartID, ByteCounter);
									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_SINGLE_CHAN_PARAM){
										privat_Set_Single_Channel_Param_packet_handler(FrameStartID, ByteCounter);
									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_PULSE_TRIGGER){
										privat_Manual_Pulse_Trigger_packet_handler(FrameStartID, ByteCounter);		
									}else{
										//Rien d'autre pour le moment
									}
									PacketRxState 	= IDLE;
							}else{														
									PacketRxState		= IDLE;				//Error non existing byte 
							}
					}else{
							ByteCounter++;
							if(ByteCounter>MAX_FRAME_SIZE){			//Frame too long -> ignored
									PacketRxState = IDLE;
							}
					}
					break;
			default:
					break;
		}
		rxBufferID++;
	}
}
//END USART_rx_handler

/**
  * @brief  Dummy, force rx_handler to ignore current packet (use when reseting uart after crash)
  */
void 			USART_RST_rx_handler(void){
	PacketRxState = IDLE;
}
//END USART_RST_rx_handler




/**
  * @brief  USART com. channel high level data handling
	* 				Pour le moment une seule action traitée
  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (MSG_TYPE_ID) of the recieved Frame in the rxDataBuffer
  * @retval None
  */
void 			privat_Debug_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	for(i=0;i<=FrameSize-2;i++){
		CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
	}
	
	if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
		LED0_GPIO_Port->ODR	^= LED0_Pin;
	}
//	if((FrameSize>=2) && (rxDataBuffer[(uint8_t)(FrameStartID+1)] == 1)){
//		MainStatus |= REQUEST_STATUS;
//	}
}
//END privat_Debug_packet_handler

/**
	* @brief  Fonction gérant les démandes de status. La requète doit avoir la forme suivante :
	*						- Message ID (MSG_TYPE_GET_STATUS uint8_t)
	*						-	Message signature (CHANNEL_ID uint7_t)
	*						- CCR (7bit)
	*					Le contenu à renvoyer comme réponse est le suivant (1+1+1+5+5+5+1 = 19 x 7bits): 
	*						- Message ID (MSG_TYPE_GET_STATUS uint8_t)
	*						-	Message signature (CHANNEL_ID uint7_t)
  * 					- Version du software (uint7_t)
	*						-	Channel status register (uint32_t (5*7bit))
	*						-	Voltage rail positif (float (5*7bit))
	*						-	Voltage rail negatif (float (5*7bit))
	*						- CCR (7bit)
  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (FRAME_START) of the recieved Frame in the rxDataBuffer
  * @retval None
  */
void 			privat_Status_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	for(i=0;i<=FrameSize-2;i++){
		CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
	}
	
	if((CCR&0x7F)!=rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
		return;
	}else{
			USART_reset_Buffer();
			if(txBufferID)	txDataBuffer1[txBufferCnt] = MSG_TYPE_GET_STATUS;
			else			txDataBuffer0[txBufferCnt] = MSG_TYPE_GET_STATUS;
			txBufferCnt++;

			//Message signature
			USART_add_7BitChar_To_TxBuffer(rxDataBuffer[(uint8_t)(FrameStartID+1)]);
			USART_add_7BitChar_To_TxBuffer(SOFTWARE_VERSION);
			USART_add_uint32_To_TxBuffer(MainStatus);
			USART_add_float_To_TxBuffer(HV_PosRailVoltage);
			USART_add_float_To_TxBuffer(HV_NegRailVoltage);		
		
			//Calcul le byte de vérification d'erreur
			CCR=0;
			if(txBufferID){
				for(i=0;i<=17;i++){
					CCR ^= txDataBuffer1[i];
				}		
			}else{
				for(i=0;i<=17;i++){
					CCR ^= txDataBuffer0[i];
				}
			}

			USART_add_7BitChar_To_TxBuffer(CCR);	
			USART_send_buffer();
	}
}
//END privat_Status_packet_handler

/**
  * @brief  Configuration de tous les paramètres du canal (voir "Channel_function.c" pour les explications des variables)
	* 				Le message doit contenir les champs suivant [var_type] (Bytes) : 
	*						- L'entête du message : 													[MSG_TYPE_ID (uint8_t)] (FrameStartID)
	*						- Durée des pulses (t1 ~ us) : 										[ uint32_t ] 						(FrameStartID+1..5)
	*						- Durée des dead time (t2 ~ us) : 								[ uint32_t ] 						(FrameStartID+6..10)
	*						- Durée entres pulses d'un même train (t3 ~ us) : [ uint32_t ] 						(FrameStartID+11..15)
	*						- Durée les trains (t4 ~ us) : 										[ uint32_t ] 						(FrameStartID+16..20)
	*						- Nb de paire de pulse par train : 								[ uint7_t ] 						(FrameStartID+21)
	*						- Intensité des pulses (I ~ mA) : 								[ float ] 							(FrameStartID+22..26)
  *						- CCR 																						[ uint7_t ] 						(FrameStartID+27)
  * @param  Variable
	* 				 	- FrameStartID 	: 	ID of the first byte (MSG_TYPE_ID) of the recieved Frame in the rxDataBuffer
  *					 	- FrameSize 		: 	Nombre de bytes 
  * @retval None
  */
void 			privat_Set_All_Channel_Param_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	if(FrameSize==28){
		for(i=0;i<=FrameSize-2;i++){
			CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
		}
		
		if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
			Channel_SetPulseWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+1)));
			Channel_SetDeadTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+6)));
			Channel_SetInterPulseTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+11)));
			Channel_SetInterFrameTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+16)));
			Channel_SetPulseRepetitionCnt(rxDataBuffer[(uint8_t)(FrameStartID+21)]);
			Channel_SetAmplitude(privat_ConvBits2float((uint8_t)(FrameStartID+22)));
			MainStatus &=~LAST_MSG_ERR;
		}else{
			MainStatus |= LAST_MSG_ERR;
		}
		
	}else if(FrameSize==29){
		for(i=0;i<=FrameSize-2;i++){
			CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
		}
		
		if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
			Channel_SetPulseWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+1)));
			Channel_SetDeadTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+6)));
			Channel_SetInterPulseTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+11)));
			Channel_SetInterFrameTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+16)));
			Channel_SetPulseRepetitionCnt(rxDataBuffer[(uint8_t)(FrameStartID+21)]);
			Channel_SetAmplitude(privat_ConvBits2float((uint8_t)(FrameStartID+22)));
			Channel_SetMode(rxDataBuffer[(uint8_t)(FrameStartID+27)]);
			MainStatus &=~LAST_MSG_ERR;
		}else{
			MainStatus |= LAST_MSG_ERR;
		}		
	}else{
		MainStatus |= LAST_MSG_ERR;
		return;
	}
	

}
//END privat_Set_All_Channel_Param_packet_handler

/**
  * @brief  Configuration d'un seul paramètre du canal (voir "Channel_function.c" pour les explications des variables)
	* 				Le message doit contenir les champs suivant [var_type] (Bytes) : 
	*						- L'entête du message : 															[MSG_TYPE_ID (uint8_t)] 		(FrameStartID)
	*						- Variable ID (1->t1,2->t2,3->t3,4->t4,5->Nb,6->I) : 	[ uint7_t ] 								(FrameStartID+1)
	*						- Variable Value : 																		[ uint32_t/float/ ] 				(FrameStartID+2..6) *Note: Dans le cas de la varialbe Nb on utilise quand même un uint32_t
  *						- CCR 																								[ uint7_t ] 								(FrameStartID+7)
	* 				
  * @param  Variable
	* 				 	- FrameStartID 	: 	ID of the first byte (MSG_TYPE_ID) of the recieved Frame in the rxDataBuffer
  *					 	- FrameSize 		: 	Nombre de bytes 
  * @retval None
  */
void 			privat_Set_Single_Channel_Param_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	if(FrameSize!=8){
		MainStatus |= LAST_MSG_ERR;
		return;
	}
	
	for(i=0;i<=FrameSize-2;i++){
		CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
	}
	
	if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
		MainStatus &=~LAST_MSG_ERR;
		switch(rxDataBuffer[(uint8_t)(FrameStartID+1)]){
			case 1: //t1
				Channel_SetPulseWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+2)));
				break;
			case 2: //t2
				Channel_SetDeadTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+2)));
				break;
			case 3: //t3
				Channel_SetInterPulseTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+2)));
				break;
			case 4: //t4
				Channel_SetInterFrameTimeWidth(privat_ConvBits2uint32((uint8_t)(FrameStartID+2)));
				break;
			case 5: //Nb
				Channel_SetPulseRepetitionCnt(privat_ConvBits2uint32((uint8_t)(FrameStartID+2))); //On utilise quand même un uint32
				break;
			case 6: //I
				Channel_SetAmplitude(privat_ConvBits2float((uint8_t)(FrameStartID+2)));
				break;
			case 7:
				Channel_SetMode(privat_ConvBits2uint32((uint8_t)(FrameStartID+2)));
				break;
			case 8:
				Channel_ManualPulseTrigger(); //Yes that's dirty
				break;
			default:
				MainStatus |= LAST_MSG_ERR;
				break;
		}

	}else{
		MainStatus |= LAST_MSG_ERR;
	}
}
//END privat_Set_Single_Channel_Param_packet_handler

/**
  * @brief  Configuration d'un seul paramètre du canal (voir "Channel_function.c" pour les explications des variables)
	* 				Le message doit contenir les champs suivant [var_type] (Bytes) : 
	*						- L'entête du message : 															[MSG_TYPE_ID (uint8_t)] 		(FrameStartID)
	*						- Variable ID (1->t1,2->t2,3->t3,4->t4,5->Nb,6->I) : 	[ uint7_t ] 								(FrameStartID+1)
	*						- Variable Value : 																		[ uint32_t/float/ ] 				(FrameStartID+2..6) *Note: Dans le cas de la varialbe Nb on utilise quand même un uint32_t
  *						- CCR 																								[ uint7_t ] 								(FrameStartID+7)
	* 				
  * @param  Variable
	* 				 	- FrameStartID 	: 	ID of the first byte (MSG_TYPE_ID) of the recieved Frame in the rxDataBuffer
  *					 	- FrameSize 		: 	Nombre de bytes 
  * @retval None
  */
void 			privat_Manual_Pulse_Trigger_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	Channel_ManualPulseTrigger();
}
//END privat_Manual_Pulse_Trigger_packet_handler








/**
  * @brief  Reconstruit un float à partir de 5 charactères (7 bites utiles) 
  * @param  Variable
	* 				 - FloatByteStartID : 	ID of the first byte of the float
  * @retval None
  */
float			privat_ConvBits2float(uint8_t FloatByteStartID){
	uint32_t TMP = 0x00000000;
	TMP = (rxDataBuffer[FloatByteStartID]<<25) | (rxDataBuffer[(uint8_t)(FloatByteStartID+1)]<<18) | (rxDataBuffer[(uint8_t)(FloatByteStartID+2)]<<11) | (rxDataBuffer[(uint8_t)(FloatByteStartID+3)]<<4) | (rxDataBuffer[(uint8_t)(FloatByteStartID+4)]>>3);
	return *((float*)&TMP);
}
//END privat_Conv2float

/**
  * @brief  Reconstruit un uint32 à partir de 5 charactères (7 bites utiles) 
  * @param  Variable
	* 				 - Uint32ByteStartID : 	ID of the first byte of the float
  * @retval None
  */
uint32_t	privat_ConvBits2uint32(uint8_t Uint32ByteStartID){
	uint32_t TMP = 0x00000000;
	TMP = (rxDataBuffer[Uint32ByteStartID]<<25) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+1)]<<18) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+2)]<<11) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+3)]<<4) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+4)]>>3);
	return TMP;
}
//END privat_ConvBits2uint32

/**
  * @brief  Ajoute 7bit (uint8_t) avec 7 bit utile au buffer d'envoi
  */
void 			USART_add_7BitChar_To_TxBuffer(uint8_t DATA){
	if(!txBufferCnt){
		if(txBufferID)
			txDataBuffer1[txBufferCnt] = TX_FRAME_START;
		else
			txDataBuffer0[txBufferCnt] = TX_FRAME_START;
		txBufferCnt++;
	}
	
	if(txBufferID){
		txDataBuffer1[txBufferCnt] = DATA & 0x7F;
	}else{
		txDataBuffer0[txBufferCnt] = DATA & 0x7F;
	}
	txBufferCnt++;	
}
//END USART_add_7BitChar_To_TxBuffer

/**
  * @brief  Ajoute un uint32_t au buffer d'envoi
  */
void 			USART_add_uint32_To_TxBuffer(uint32_t DATA){

	if(!txBufferCnt){
		if(txBufferID)
			txDataBuffer1[txBufferCnt] = TX_FRAME_START;
		else
			txDataBuffer0[txBufferCnt] = TX_FRAME_START;
		txBufferCnt++;
	}

	if(txBufferID){
		txDataBuffer1[txBufferCnt]=((uint8_t)(DATA>>25))&0x7F;
		txDataBuffer1[txBufferCnt+1]=((uint8_t)(DATA>>18))&0x7F;
		txDataBuffer1[txBufferCnt+2]=((uint8_t)(DATA>>11))&0x7F;
		txDataBuffer1[txBufferCnt+3]=((uint8_t)(DATA>>4))&0x7F;
		txDataBuffer1[txBufferCnt+4]=((uint8_t)(DATA<<3))&0x7F;
	}else{
		txDataBuffer0[txBufferCnt]=((uint8_t)(DATA>>25))&0x7F;
		txDataBuffer0[txBufferCnt+1]=((uint8_t)(DATA>>18))&0x7F;
		txDataBuffer0[txBufferCnt+2]=((uint8_t)(DATA>>11))&0x7F;
		txDataBuffer0[txBufferCnt+3]=((uint8_t)(DATA>>4))&0x7F;
		txDataBuffer0[txBufferCnt+4]=((uint8_t)(DATA<<3))&0x7F;
	}
	txBufferCnt+=5;	
}
//END USART_add_uint32_To_TxBuffer

/**
  * @brief  Ajoute une variable de type "float" au buffer d'envoie
  */
void 			USART_add_float_To_TxBuffer(float DATA){
	uint32_t TMP=*((uint32_t*)&	DATA);
	if(!txBufferCnt){
		if(txBufferID)
			txDataBuffer1[txBufferCnt] = TX_FRAME_START;
		else
			txDataBuffer0[txBufferCnt] = TX_FRAME_START;
		txBufferCnt++;
	}

	if(txBufferID){
		txDataBuffer1[txBufferCnt]=((uint8_t)(TMP>>25));
		txDataBuffer1[txBufferCnt+1]=((uint8_t)(TMP>>18))&0x7F;
		txDataBuffer1[txBufferCnt+2]=((uint8_t)(TMP>>11))&0x7F;
		txDataBuffer1[txBufferCnt+3]=((uint8_t)(TMP>>4))&0x7F;
		txDataBuffer1[txBufferCnt+4]=((uint8_t)(TMP<<3))&0x7F;
	}else{
		txDataBuffer0[txBufferCnt]=((uint8_t)(TMP>>25));
		txDataBuffer0[txBufferCnt+1]=((uint8_t)(TMP>>18))&0x7F;
		txDataBuffer0[txBufferCnt+2]=((uint8_t)(TMP>>11))&0x7F;
		txDataBuffer0[txBufferCnt+3]=((uint8_t)(TMP>>4))&0x7F;
		txDataBuffer0[txBufferCnt+4]=((uint8_t)(TMP<<3))&0x7F;
	}
	txBufferCnt+=5;	
}
//END USART_add_float_To_TxBuffer

/**
  * @brief  Vide le buffer d'envoie 
	* 				Utile dans le cas d'une communication assychrone :
	*						Si une version plus réssente des donnés déjà présentes dans le buffer d'envoie existe alors on
	*						vide le buffer et on met les données les plus réssentes à la place
  */
void 			USART_reset_Buffer(void){
	txBufferCnt = 0;
}
//END USART_reset_Buffer

/**
  * @brief  Envois le contenu du buffer d'envois en cours d'utilisation via UART et passe au second buffer
  */
void 			USART_send_buffer(void){
	if(txBufferID){
		txDataBuffer1[txBufferCnt] = MSG_STOP;
		txBufferCnt++;
		HAL_UART_Transmit_DMA(&huart3, txDataBuffer1, txBufferCnt);
		txBufferID = 0;
	}else{
		txDataBuffer0[txBufferCnt] = MSG_STOP;
		txBufferCnt++;
		HAL_UART_Transmit_DMA(&huart3, txDataBuffer0, txBufferCnt);
		txBufferID = 1;
	}
	txBufferCnt = 0;
}
//END USART_send_buffer



