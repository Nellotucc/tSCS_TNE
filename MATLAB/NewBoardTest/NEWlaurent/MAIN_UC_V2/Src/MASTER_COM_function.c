/**
  ******************************************************************************
  * @file    	MASTER_COM_function.c
  * @author  	Laurent Jenni (EPFL-LSRO)
  * @version 	V1.1.0
  * @date    	May.2017
  * @brief   	Contient les fonctions de communication avec le PC h�te
	*					  Contient �galement les fonctions de gestion de la liaison UART (uart2) d�di�e � communiquer avec le PC
  * @verbatim	-
  ******************************************************************************	
  */

#include "MASTER_COM_function.h"
#include "CHANNEL_COM_function.h"
#include "MISC_function.h"
//#include "main.h"


/*
* The Start frame define what inside the packet
*/

// Liste des ent�tes pour les diff�rents type de messages
#define MSG_TYPE_DEBUG                           ((uint8_t)0xFF)     //Message r�serv� pour le d�buggage
#define MSG_TYPE_SET_SINGLE_CHAN_STATE           ((uint8_t)0xDF)     //Change l'�tat d'activation d'un seul canal
#define MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM       ((uint8_t)0xDC)     //Change tout les param�tres de pulse d'un seul canal
#define MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM    ((uint8_t)0xDD)     //Change un param�tre de pulse d'un seul canal
#define MSG_TYPE_SET_ALL_CHAN_ALL_PARAM          ((uint8_t)0xDA)     //Change tout les param�tres de pulse de tous les canaux(identique pour tous)
//#define MSG_TYPE_SET_SINGLE_CHAN_MODE
//#define MSG_TYPE_SET_SINGLE_CHAN_MODE
//#define MSG_TYPE_SET_ALL_CHAN_PARAM            ((uint8_t)0xFE) 							//Message contenant tous les param�tres du canal (voir "privat_Set_All_Channel_Param_packet_handler" pour les d�tails
#define MSG_TYPE_MIN_ID	                         ((uint8_t)0xAB) 							//Start frame min 
#define MSG_STOP                                 ((uint8_t)0x80)								//Stop frame

#define MIN_FRAME_SIZE							1
#define MAX_FRAME_SIZE							200
#define RX_BUFFER_SIZE							256
#define TX_BUFFER_SIZE							256



extern UART_HandleTypeDef  huart2;
extern DMA_HandleTypeDef   hdma_usart2_rx;

extern volatile uint32_t   MainStatus;


/* Possible states for packet reception process	*/
typedef enum{ 
  IDLE,							//Waiting for downstream data frame to start (== 'waiting for FRAME_START')
  DATA_PENDING,  		//Waiting for data or 'FRAME_STOP'
}PacketRxStateEnum;
//END typedef

static uint8_t						rxDataBuffer[RX_BUFFER_SIZE];
static PacketRxStateEnum 	PacketRxState = IDLE;

static uint8_t 						txDataBuffer0[TX_BUFFER_SIZE];
static uint8_t 						txDataBuffer1[TX_BUFFER_SIZE];
static uint8_t						txBufferCnt 	= 0x00;
static uint8_t						txBufferID 	  = 0x00;

/* Private function prototypes -----------------------------------------------*/
static void			privat_Debug_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
static void			privat_SetChannelState_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
static void			privat_SetChannelParam_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
static float		privat_ConvBits2float(uint8_t FloatByteStartID);
static uint32_t	    privat_ConvBits2uint32(uint8_t Uint32ByteStartID);
//static void			privat_UART_add_7BitChar_To_TxBuffer(uint8_t DATA);
//static void			privat_UART_add_uint32_To_TxBuffer(uint32_t DATA);
//static void			privat_UART_add_float_To_TxBuffer(float DATA);
//static void			privat_UART_send_buffer(void);
//static void			privat_UART_reset_Buffer(void);




/**
  * @brief  Init RX
  * @param  rxData
  * @retval None
  */
void 	MASTER_UART_rx_init(void){
	HAL_UART_Receive_DMA(&huart2, rxDataBuffer, RX_BUFFER_SIZE);
}
//END MASTER_UART_rx_init

/**
  * @brief  UART channel low level data handling 
	*					Should be called periodicaly to check if there are new datas in "rxDataBuffer" and process them
  * @param  None
  * @retval None, the function call directly 'USART_packet_handler(..)' to process recieved data/request
  */
void 	MASTER_UART_rx_handler(void){
	static uint8_t	rxBufferID=0, FrameStartID=0, ByteCounter=0;
	uint8_t 				rxBufferTop,	dataTmp;
	
	rxBufferTop = (uint8_t)(RX_BUFFER_SIZE - hdma_usart2_rx.Instance->CNDTR);
	
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
									}else if	(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_SINGLE_CHAN_STATE){
										privat_SetChannelState_packet_handler(FrameStartID, ByteCounter);
//									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM){
//										privat_SetChannelParam_packet_handler(FrameStartID, ByteCounter);
//									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM){
//										privat_SetChannelParam_packet_handler(FrameStartID, ByteCounter);
//									}else if(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_ALL_CHAN_ALL_PARAM){
//										privat_SetChannelParam_packet_handler(FrameStartID, ByteCounter);
									}else if(	(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM) || 
														(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM) ||
														(rxDataBuffer[(uint8_t)(FrameStartID)]==MSG_TYPE_SET_ALL_CHAN_ALL_PARAM)){
										privat_SetChannelParam_packet_handler(FrameStartID, ByteCounter);
									}else{
										//Pour le moment rien d'autre
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
//END MASTER_UART_rx_handler

/**
  * @brief  Dummy, force rx_handler to ignore current packet (use when reseting uart after crash)
  */
void	MASTER_UART_RST_rx_handler(void){
	PacketRxState = IDLE;
}
//END MASTER_UART_RST_rx_handler





/**
  * @brief  USART com. channel high level data handling
  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (FRAME_START) of the recieved Frame in the rxDataBuffer
	*					 - FrameSize 		: 	Should be equal to 7
  * @retval None
  */
static void		privat_Debug_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	#ifdef PROTO_BOARD
		LED_GPIO_Port->ODR ^= LED_Pin;
	#endif
}
//END privat_Debug_packet_handler

/**
	* @brief  PROTO: Cette fonction traite les requ�tes envoy�es depuis le PC concernant l'activation/d�sactivation des cannaux
	* 				Pour le moment �a ne concerne que les requ�tes avec l'ID :
	* 					MSG_TYPE_SET_SINGLE_CHAN_STATE	((uint8_t)0xDF)	
  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (FRAME_START) of the recieved Frame in the rxDataBuffer
	*					 - FrameSize 		: 	Should be equal to 7
  * @retval None
  */
static void		privat_SetChannelState_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	switch( rxDataBuffer[FrameStartID] ){
		case MSG_TYPE_SET_SINGLE_CHAN_STATE :
			for(i=0;i<=FrameSize-2;i++){
				CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
			}
			
			if((FrameSize==4) && ((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)])){
				CHANNEL_cmd(rxDataBuffer[(uint8_t)(FrameStartID+1)], rxDataBuffer[(uint8_t)(FrameStartID+2)]&0x01, rxDataBuffer[(uint8_t)(FrameStartID+2)]&0x02, rxDataBuffer[(uint8_t)(FrameStartID+2)]&0x04);
			}
			break;
		default :
			break;
		}
}
//END privat_SetChannelState_packet_handler

/**
	* @brief  PROTO :Cette fonction traite les requ�tes envoy�es depuis le PC concernant le changement des param�tres des pulses des cannaux
	*					Pour le moment �a consiste b�tement � copier le message envoy� du PC telquel et l'envoyer vers le cannal concern�
	* 				Pour le moment �a ne concerne que les requ�tes avec les IDs suivantes :
	*
	* 					MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM	((uint8_t)0xDD)
	*								- Le message re�us doit contenir les champs suivant [var_type] (Bytes) : 
	*										- L'ent�te du message : 															[MSG_TYPE_ID (uint8_t)] (FrameStartID)
	*										- L'ID du canal : 																		[ uint7_t  ] 						(FrameStartID+1)
	*										- Variable ID (1->t1,2->t2,3->t3,4->t4,5->Nb,6->I) : 	[ uint7_t ] 						(FrameStartID+2)
	*										- Variable Value : 																		[ uint32_t/float/ ] 		(FrameStartID+3..7) *Note: Dans le cas de la varialbe Nb on utilise quand m�me un uint32_t
  *										- CCR 																								[ uint7_t ] 						(FrameStartID+8)
	*								- Il est transmis quasi � l'identique � part que l'ID du cannal est suprim� (et le CCR corrig�) voir pour faire autrement car l� on convertis tt les donn�es re�ues du PC en INT et FLOAT pour les reconvertir d�ri�re en trame uart...
	*
	* 					MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM		((uint8_t)0xDC) 
	*					&	MSG_TYPE_SET_ALL_CHAN_ALL_PARAM				((uint8_t)0xDA)
	*								- Le message re�us doit contenir les champs suivant [var_type] (Bytes) : 
	*										- L'ent�te du message : 													[MSG_TYPE_ID (uint8_t)] (FrameStartID)
	*										- L'ID du canal (pas utilis� si "ALL_CHAN"): 			[ uint7_t  ] 						(FrameStartID+1)
	*										- Dur�e des pulses (t1 ~ us) : 										[ uint32_t ] 						(FrameStartID+2..6)
	*										- Dur�e des dead time (t2 ~ us) : 								[ uint32_t ] 						(FrameStartID+7..11)
	*										- Dur�e entres pulses d'un m�me train (t3 ~ us) : [ uint32_t ] 						(FrameStartID+12..16)
	*										- Dur�e les trains (t4 ~ us) : 										[ uint32_t ] 						(FrameStartID+17..21)
	*										- Nb de paire de pulse par train : 								[ uint7_t  ] 						(FrameStartID+22)
	*										- Intensit� des pulses (I ~ mA) : 								[ float    ] 						(FrameStartID+23..27)
  *										- CCR 																						[ uint7_t  ] 						(FrameStartID+28)
	*								- M�me remarque qu'en dessus
	* 					

  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (FRAME_START) of the recieved Frame in the rxDataBuffer
	*					 - FrameSize 		: 	Should be equal to 7
  * @retval None
  */
static void		privat_SetChannelParam_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	switch( rxDataBuffer[FrameStartID] ){
		case MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM :
		case MSG_TYPE_SET_ALL_CHAN_ALL_PARAM :
				if(FrameSize==29){			
					for(i=0;i<=FrameSize-2;i++){
						CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
					}
					
					if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
						if(rxDataBuffer[FrameStartID] == MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM){
							CHANNEL_Set_Single_Channel_All_Param( 
																 rxDataBuffer[(uint8_t)(FrameStartID+1)], 						//CHANNEL_ID
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+2)),		//t1 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+7)),		//t2 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+12)),	//t3 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+17)),	//t4 ~ us
																 rxDataBuffer[(uint8_t)(FrameStartID+22)],				//Nb nombre de pulses par train
																 privat_ConvBits2float((uint8_t)(FrameStartID+23)));	//I ~ mA
						}else{
							for(i=0;i<=15;i++){
								if(CHANNEL_Set_Single_Channel_All_Param( 
																 i, 																									//CHANNEL_ID
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+2)),		//t1 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+7)),		//t2 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+12)),	//t3 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+17)),	//t4 ~ us
																 rxDataBuffer[(uint8_t)(FrameStartID+22)],				//Nb nombre de pulses par train
																 privat_ConvBits2float((uint8_t)(FrameStartID+23)))	    //I ~ mA
										)
										Delay_ms_dummy(1);
								}
						}
					}
				}else if(FrameSize==30){
					for(i=0;i<=FrameSize-2;i++){
						CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
					}
					
					if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
						if(rxDataBuffer[FrameStartID] == MSG_TYPE_SET_SINGLE_CHAN_ALL_PARAM){
							CHANNEL_Set_Single_Channel_All_Param_v2( 
																 rxDataBuffer[(uint8_t)(FrameStartID+1)], 						//CHANNEL_ID
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+2)),		//t1 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+7)),		//t2 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+12)),	//t3 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+17)),	//t4 ~ us
																 rxDataBuffer[(uint8_t)(FrameStartID+22)],				//Nb nombre de pulses par train
																 privat_ConvBits2float((uint8_t)(FrameStartID+23)),		//I ~ mA
																 rxDataBuffer[(uint8_t)(FrameStartID+28)]);
						}else{
							for(i=0;i<=15;i++){
								if(CHANNEL_Set_Single_Channel_All_Param_v2( 
																 i, 																									//CHANNEL_ID
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+2)),		//t1 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+7)),		//t2 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+12)),	//t3 ~ us
																 privat_ConvBits2uint32((uint8_t)(FrameStartID+17)),	//t4 ~ us
																 rxDataBuffer[(uint8_t)(FrameStartID+22)],				//Nb nombre de pulses par train
																 privat_ConvBits2float((uint8_t)(FrameStartID+23)),		//I ~ mA
																 rxDataBuffer[(uint8_t)(FrameStartID+28)])
										)
										Delay_ms_dummy(1);
								}
						}
					}					
				}
				break;
				
		case MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM :
				if(FrameSize!=9)
					return;
				for(i=0;i<=FrameSize-2;i++){
					CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
				}
				if((CCR&0x7F)==rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
					CHANNEL_Set_Single_Channel_Single_Param( 
												rxDataBuffer[(uint8_t)(FrameStartID+1)], 						//CHANNEL_ID
												rxDataBuffer[(uint8_t)(FrameStartID+2)], 						//VAR_ID
												privat_ConvBits2uint32((uint8_t)(FrameStartID+3)));	//DATA
				}			
				break;
		default :
				break;
		}
}
//END privat_SetChannelParam_packet_handler




/**
  * @brief  Reconstruit un float � partir de 5 charact�res (7 bites utiles) 
  * @param  Variable
	* 				 - FloatByteStartID : 	ID of the first byte of the float
  * @retval None
  */
static float		privat_ConvBits2float(uint8_t FloatByteStartID){
	uint32_t TMP = 0x00000000;
	TMP = (rxDataBuffer[FloatByteStartID]<<25) | (rxDataBuffer[(uint8_t)(FloatByteStartID+1)]<<18) | (rxDataBuffer[(uint8_t)(FloatByteStartID+2)]<<11) | (rxDataBuffer[(uint8_t)(FloatByteStartID+3)]<<4) | (rxDataBuffer[(uint8_t)(FloatByteStartID+4)]>>3);
	return *((float*)&TMP);
}
//END privat_ConvBits2float

/**
  * @brief  Reconstruit un uint32 � partir de 5 charact�res (7 bites utiles) 
  * @param  Variable
	* 				 - Uint32ByteStartID : 	ID of the first byte of the float
  * @retval None
  */
static uint32_t		privat_ConvBits2uint32(uint8_t Uint32ByteStartID){
	uint32_t TMP = 0x00000000;
	TMP = (rxDataBuffer[Uint32ByteStartID]<<25) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+1)]<<18) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+2)]<<11) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+3)]<<4) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+4)]>>3);
	return TMP;
}
//END privat_ConvBits2uint32

///**
//  * @brief  Ajoute 7bit (uint8_t) avec 7 bit utile au buffer d'envoi
//  */
//static void		privat_UART_add_7BitChar_To_TxBuffer(uint8_t DATA){

//	if(txBufferID){
//		txDataBuffer1[txBufferCnt] = DATA & 0x7F;
//	}else{
//		txDataBuffer0[txBufferCnt] = DATA & 0x7F;
//	}
//	txBufferCnt++;	
//}
////END privat_UART_add_7BitChar_To_TxBuffer

///**
//  * @brief  Ajoute un uint32_t au buffer d'envoi
//  */
//static void		privat_UART_add_uint32_To_TxBuffer(uint32_t DATA){

//	if(txBufferID){
//		txDataBuffer1[txBufferCnt]=((uint8_t)(DATA>>25))&0x7F;
//		txDataBuffer1[txBufferCnt+1]=((uint8_t)(DATA>>18))&0x7F;
//		txDataBuffer1[txBufferCnt+2]=((uint8_t)(DATA>>11))&0x7F;
//		txDataBuffer1[txBufferCnt+3]=((uint8_t)(DATA>>4))&0x7F;
//		txDataBuffer1[txBufferCnt+4]=((uint8_t)(DATA<<3))&0x7F;
//	}else{
//		txDataBuffer0[txBufferCnt]=((uint8_t)(DATA>>25))&0x7F;
//		txDataBuffer0[txBufferCnt+1]=((uint8_t)(DATA>>18))&0x7F;
//		txDataBuffer0[txBufferCnt+2]=((uint8_t)(DATA>>11))&0x7F;
//		txDataBuffer0[txBufferCnt+3]=((uint8_t)(DATA>>4))&0x7F;
//		txDataBuffer0[txBufferCnt+4]=((uint8_t)(DATA<<3))&0x7F;
//	}
//	txBufferCnt+=5;	
//}
////END privat_UART_add_uint32_To_TxBuffer

///**
//  * @brief  Ajoute une variable de type "float" au buffer d'envoie
//  */
//static void		privat_UART_add_float_To_TxBuffer(float DATA){
//	uint32_t TMP=*((uint32_t*)&	DATA);

//	if(txBufferID){
//		txDataBuffer1[txBufferCnt]=((uint8_t)(TMP>>25));
//		txDataBuffer1[txBufferCnt+1]=((uint8_t)(TMP>>18))&0x7F;
//		txDataBuffer1[txBufferCnt+2]=((uint8_t)(TMP>>11))&0x7F;
//		txDataBuffer1[txBufferCnt+3]=((uint8_t)(TMP>>4))&0x7F;
//		txDataBuffer1[txBufferCnt+4]=((uint8_t)(TMP<<3))&0x7F;
//	}else{
//		txDataBuffer0[txBufferCnt]=((uint8_t)(TMP>>25));
//		txDataBuffer0[txBufferCnt+1]=((uint8_t)(TMP>>18))&0x7F;
//		txDataBuffer0[txBufferCnt+2]=((uint8_t)(TMP>>11))&0x7F;
//		txDataBuffer0[txBufferCnt+3]=((uint8_t)(TMP>>4))&0x7F;
//		txDataBuffer0[txBufferCnt+4]=((uint8_t)(TMP<<3))&0x7F;
//	}
//	txBufferCnt+=5;	
//}
////END privat_UART_add_float_To_TxBuffer

///**
//  * @brief  Vide le buffer d'envoie 
//	* 				Utile dans le cas d'une communication assychrone :
//	*						Si une version plus r�ssente des donn�s d�j� pr�sentes dans le buffer d'envoie existe alors on
//	*						vide le buffer et on met les donn�es les plus r�ssentes � la place
//  */
//static void		privat_UART_reset_Buffer(void){
//	txBufferCnt = 0;
//}
////END privat_UART_reset_Buffer

///**
//  * @brief  Envois le contenu du buffer d'envois en cours d'utilisation via UART et passe au second buffer
//  */
//static void		privat_UART_send_buffer(void){
//	if(txBufferID){
//		txDataBuffer1[txBufferCnt] = MSG_STOP;
//		txBufferCnt++;
//		HAL_UART_Transmit_DMA(&huart3, txDataBuffer1, txBufferCnt);
//		txBufferID = 0;
//	}else{
//		txDataBuffer0[txBufferCnt] = MSG_STOP;
//		txBufferCnt++;
//		HAL_UART_Transmit_DMA(&huart3, txDataBuffer0, txBufferCnt);
//		txBufferID = 1;
//	}
//	txBufferCnt = 0;
//}
////END privat_UART_send_buffer







