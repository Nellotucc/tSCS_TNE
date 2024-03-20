/**
  ******************************************************************************
  * @file    	CHANNEL_COM_function.c
  * @author  	Laurent Jenni (EPFL-LSRO)
  * @version 	V1.1.0
  * @date    	May.2017
  * @brief   	Contient les fonctions permétant de configurer les cannaux du stimulateur.
	*					  Contient également les fonctions de gestion de la liaison UART (uart3) dédiée
	*						à communiquer avec les cannaux
  * @verbatim	-
  ******************************************************************************	
  */
	
#include "CHANNEL_COM_function.h"
#include "MISC_function.h"


#define DELAY_1000US Delay_us_dummy(1000)

/*
* The Start frame define what inside the packet
*/

// Liste des entêtes pour les différents type de messages
#define 		MSG_TYPE_DEBUG							((uint8_t)0xFF) 							//Message réservé pour le débuggage
#define 		MSG_TYPE_GET_STATUS					((uint8_t)0xFE) 							//Message utilisé à l'initialisation pour vérifier si le channel fonctionne et pour récuperer son status
#define 		MSG_TYPE_SET_ALL_CHAN_PARAM	((uint8_t)0xDC) 							//Message contenant tous les paramètres du canal (voir "privat_Set_All_Channel_Param_packet_handler" pour les détails
#define			MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM	((uint8_t)0xDD)			//Message contenant un paramètre du canal
#define 		MSG_TYPE_MIN_ID							((uint8_t)0xAB) 							//Start frame min 
#define 		MSG_STOP										((uint8_t)0x80)								//Stop frame

#define 		MIN_FRAME_SIZE							1
#define 		MAX_FRAME_SIZE							200
#define 		RX_BUFFER_SIZE							256
#define 		TX_BUFFER_SIZE							256

// Liste des bits du registre "ChannelComStatus"
#define			LAST_RX_FRAME_OK						((uint32_t)0x00000001)				//Dernier message reçu correctement
#define			LAST_RX_FRAME_FAULT					((uint32_t)0x00000002)				//Dernier message reçu incorrectement

// Liste des bits des registres "channelTypeDef.Channel_General_Status"
#define			CHANNEL_DETECTED						((uint32_t)0x00000001)				//Set if channel is responding request
#define			CHANNEL_NOT_RESPONDING			((uint32_t)0x00000002)				//Set if channel is not responding request
#define			CHANNEL_COMMUNICATION_FAULT	((uint32_t)0x00000004)				//Erreur non spécifique (le cannal répond mais la comunication est erronée)
#define 		CHANNEL_CRITICAL_FAULT			((uint32_t)0x00000008)				//Erreur critique non spécifique si ce bit est à 1 la haute tension et la sortie du canal ne peuveut pas être activées
																																			//  (pour le moment utilisé seulement si un UNDER/OVERVOLTAGE est détecté pendant le test du canal)
#define 		CHANNEL_HV_UNDERVOLTAGE_WARNING	((uint32_t)0x00000800)		//Erreur tension HV trop basse
#define 		CHANNEL_HV_OVERVOLTAGE_WARNING	((uint32_t)0x00001000)		//Erreur tension HV trop haute
#define 		CHANNEL_HV_UNBALANCED_WARNING		((uint32_t)0x00002000)		//Erreur tension HV trop déséquilibrée entre le rail positif et le rail négatif
#define 		CHANNEL_EN									((uint32_t)0x00004000)				//Cannal allimenté
#define 		CHANNEL_HV_EN								((uint32_t)0x00008000)				//Convertisseur haute tension activé
#define 		CHANNEL_OUT_EN							((uint32_t)0x00010000)				//Sortie activée


#define			CHANNEL_TEST_ATTEMP_CNT							2											//Nombre de tentative d'initialisation des cannaux avant de definir "CHANNEL_CRITICAL_FAULT"
#define 		CHANNEL_HV_UNDERVOLTAGE_WARNING_TH	50.0f								//Tension minimale (valeur absolue) pour les rails haute tension 		/ was 150
#define 		CHANNEL_HV_OVERVOLTAGE_WARNING_TH		250.0f								//Tension maximale (valeur absolue) pour les rails haute tension
#define 		CHANNEL_HV_UNBALANCED_WARNING_TH		50.0f									//Différance maximale entre les valeurs (absolue) des hautes tensions


typedef struct{
	uint32_t						Channel_General_Status;
	uint32_t						Channel_Status_Reg;
	uint8_t							Channel_Software_version;
	float 							Channel_Voltage_Pos;
	float 							Channel_Voltage_Neg;
	uint16_t 			const CHANNEL_EN_pin;
	uint16_t 			const CHANNEL_HV_EN_pin;
	uint16_t 			const CHANNEL_OUT_EN_pin;
	GPIO_TypeDef *const CHANNEL_EN_port;
	GPIO_TypeDef *const CHANNEL_HV_EN_port;
	GPIO_TypeDef *const CHANNEL_OUT_EN_port;
	uint16_t 			const UART_MUX_pin;
}channelTypeDef;
//

//Note : le registre "Channel_General_Status" est initialisé à "CHANNEL_CRITICAL_FAULT" pour que la haute tension ne puisse pas être activée si la fonction "CHANNEL_Initial_Test_All" n'est pas executée une fois
#ifdef PROTO_BOARD
	#define 	CHANNEL_CNT							1
	channelTypeDef CHANNELS[CHANNEL_CNT] = {
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH3_EN_Pin, CH3_HV_CONV_EN_Pin, CH3_HV_OUT_EN_Pin, CH3_EN_GPIO_Port, CH3_HV_CONV_EN_GPIO_Port, CH3_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_MUX1_Pin|USART3_SUB_MUX1_Pin}
	};
#else
	#define 	CHANNEL_CNT							16
	channelTypeDef CHANNELS[CHANNEL_CNT] = {
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH0_EN_Pin, CH0_HV_CONV_EN_Pin, CH0_HV_OUT_EN_Pin, CH0_EN_GPIO_Port, CH0_HV_CONV_EN_GPIO_Port, CH0_HV_OUT_EN_GPIO_Port, USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH1_EN_Pin, CH1_HV_CONV_EN_Pin, CH1_HV_OUT_EN_Pin, CH1_EN_GPIO_Port, CH1_HV_CONV_EN_GPIO_Port, CH1_HV_OUT_EN_GPIO_Port, USART3_MUX1_Pin|USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH2_EN_Pin, CH2_HV_CONV_EN_Pin, CH2_HV_OUT_EN_Pin, CH2_EN_GPIO_Port, CH2_HV_CONV_EN_GPIO_Port, CH2_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH3_EN_Pin, CH3_HV_CONV_EN_Pin, CH3_HV_OUT_EN_Pin, CH3_EN_GPIO_Port, CH3_HV_CONV_EN_GPIO_Port, CH3_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_MUX1_Pin|USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH4_EN_Pin, CH4_HV_CONV_EN_Pin, CH4_HV_OUT_EN_Pin, CH4_EN_GPIO_Port, CH4_HV_CONV_EN_GPIO_Port, CH4_HV_OUT_EN_GPIO_Port, USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH5_EN_Pin, CH5_HV_CONV_EN_Pin, CH5_HV_OUT_EN_Pin, CH5_EN_GPIO_Port, CH5_HV_CONV_EN_GPIO_Port, CH5_HV_OUT_EN_GPIO_Port, USART3_MUX1_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH6_EN_Pin, CH6_HV_CONV_EN_Pin, CH6_HV_OUT_EN_Pin, CH6_EN_GPIO_Port, CH6_HV_CONV_EN_GPIO_Port, CH6_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH7_EN_Pin, CH7_HV_CONV_EN_Pin, CH7_HV_OUT_EN_Pin, CH7_EN_GPIO_Port, CH7_HV_CONV_EN_GPIO_Port, CH7_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_MUX1_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH8_EN_Pin, CH8_HV_CONV_EN_Pin, CH8_HV_OUT_EN_Pin, CH8_EN_GPIO_Port, CH8_HV_CONV_EN_GPIO_Port, CH8_HV_OUT_EN_GPIO_Port, 			 USART3_MUX2_Pin|USART3_MUX1_Pin|USART3_MUX0_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH9_EN_Pin, CH9_HV_CONV_EN_Pin, CH9_HV_OUT_EN_Pin, CH9_EN_GPIO_Port, CH9_HV_CONV_EN_GPIO_Port, CH9_HV_OUT_EN_GPIO_Port, 			 USART3_MUX2_Pin|USART3_MUX0_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH10_EN_Pin, CH10_HV_CONV_EN_Pin, CH10_HV_OUT_EN_Pin, CH10_EN_GPIO_Port, CH10_HV_CONV_EN_GPIO_Port, CH10_HV_OUT_EN_GPIO_Port, USART3_MUX1_Pin|USART3_MUX0_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH11_EN_Pin, CH11_HV_CONV_EN_Pin, CH11_HV_OUT_EN_Pin, CH11_EN_GPIO_Port, CH11_HV_CONV_EN_GPIO_Port, CH11_HV_OUT_EN_GPIO_Port, USART3_MUX0_Pin|USART3_SUB_MUX0_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH12_EN_Pin, CH12_HV_CONV_EN_Pin, CH12_HV_OUT_EN_Pin, CH12_EN_GPIO_Port, CH12_HV_CONV_EN_GPIO_Port, CH12_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_MUX1_Pin|USART3_MUX0_Pin|USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH13_EN_Pin, CH13_HV_CONV_EN_Pin, CH13_HV_OUT_EN_Pin, CH13_EN_GPIO_Port, CH13_HV_CONV_EN_GPIO_Port, CH13_HV_OUT_EN_GPIO_Port, USART3_MUX2_Pin|USART3_MUX0_Pin|USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH14_EN_Pin, CH14_HV_CONV_EN_Pin, CH14_HV_OUT_EN_Pin, CH14_EN_GPIO_Port, CH14_HV_CONV_EN_GPIO_Port, CH14_HV_OUT_EN_GPIO_Port, USART3_MUX1_Pin|USART3_MUX0_Pin|USART3_SUB_MUX1_Pin},
		{CHANNEL_CRITICAL_FAULT, 0x00000000, 0x00, 0.0, 0.0, CH15_EN_Pin, CH15_HV_CONV_EN_Pin, CH15_HV_OUT_EN_Pin, CH15_EN_GPIO_Port, CH15_HV_CONV_EN_GPIO_Port, CH15_HV_OUT_EN_GPIO_Port, USART3_MUX0_Pin|USART3_SUB_MUX1_Pin}
	};
#endif
//

extern UART_HandleTypeDef huart3;
extern DMA_HandleTypeDef 	hdma_usart3_rx;

extern volatile uint32_t	MainStatus;
	
extern volatile float 		DebugVar0;
extern volatile float 		DebugVar1;
extern volatile uint32_t	DebugVar2;

/* Possible states for packet reception process	*/
typedef enum{ 
  IDLE,							//Waiting for downstream data frame to start (== 'waiting for FRAME_START')
  DATA_PENDING,  		//Waiting for data or 'FRAME_STOP'
}PacketRxStateEnum;
//END typedef

static uint32_t						ChannelComStatus 	= 0x00000000;
static uint8_t 						CurrentlyAddressedChannel = 0xFF;

static uint8_t						rxDataBuffer[RX_BUFFER_SIZE];
static PacketRxStateEnum 	PacketRxState = IDLE;

static uint8_t 						txDataBuffer0[TX_BUFFER_SIZE];
static uint8_t 						txDataBuffer1[TX_BUFFER_SIZE];
static uint8_t						txBufferCnt 	= 0x00;
static uint8_t						txBufferID 	  = 0x00;

/* Private function prototypes -----------------------------------------------*/
static void 		privat_Debug_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
static void 		privat_Status_packet_handler(uint8_t FrameStartID, uint8_t FrameSize);
static float		privat_ConvBits2float(uint8_t FloatByteStartID);
static uint32_t	privat_ConvBits2uint32(uint8_t Uint32ByteStartID);
static void 		privat_UART_add_7BitChar_To_TxBuffer(uint8_t DATA);
static void 		privat_UART_add_uint32_To_TxBuffer(uint32_t DATA);
static void 		privat_UART_add_float_To_TxBuffer(float DATA);
static void 		privat_UART_send_buffer(void);
static void 		privat_UART_reset_Buffer(void);


/**
  * @brief  Test tous les cannaux. 
	*						Unique fonction pouvant mettre le bit "CHANNELS[X].Channel_General_Status & CHANNEL_CRITICAL_FAULT" à 0 (ce bit est à 1 par défaut au démarage
	*						La fonction doit conc être executée au lancement sinon la haute tension et la sortie des cannaux ne peuvent pas être activées
  */
void 			CHANNEL_Initial_Test_All(void){ 
	uint8_t i=0;
	uint8_t j=0;
	
	for(i=0;i<CHANNEL_CNT;i++){
		CHANNELS[i].Channel_General_Status &=~CHANNEL_CRITICAL_FAULT;
		CHANNEL_cmd(i, ENABLE, ENABLE, DISABLE);
	}
	
	Delay_ms_dummy(2000);	//Laisse le temps à la haute tension de se charger
	
	for(i=0;i<CHANNEL_CNT;i++){ // Possibilidade de comentar essa função
		for(j=0;j<CHANNEL_TEST_ATTEMP_CNT;j++){
				CHANNEL_get_full_status(i);
				if(CHANNELS[i].Channel_General_Status & CHANNEL_DETECTED){
						if((CHANNELS[i].Channel_Voltage_Pos<CHANNEL_HV_UNDERVOLTAGE_WARNING_TH) || (CHANNELS[i].Channel_Voltage_Neg>(-CHANNEL_HV_UNDERVOLTAGE_WARNING_TH)) )
							CHANNELS[i].Channel_General_Status |= (CHANNEL_HV_UNDERVOLTAGE_WARNING | CHANNEL_CRITICAL_FAULT);
						if((CHANNELS[i].Channel_Voltage_Pos>CHANNEL_HV_OVERVOLTAGE_WARNING_TH) || (CHANNELS[i].Channel_Voltage_Neg<(-CHANNEL_HV_OVERVOLTAGE_WARNING_TH)) )
							CHANNELS[i].Channel_General_Status |= (CHANNEL_HV_OVERVOLTAGE_WARNING | CHANNEL_CRITICAL_FAULT);
						if(((CHANNELS[i].Channel_Voltage_Pos+CHANNELS[i].Channel_Voltage_Neg)<(-CHANNEL_HV_UNBALANCED_WARNING_TH)) || ((CHANNELS[i].Channel_Voltage_Pos+CHANNELS[i].Channel_Voltage_Neg)>CHANNEL_HV_UNBALANCED_WARNING_TH) )
							CHANNELS[i].Channel_General_Status |= (CHANNEL_HV_UNBALANCED_WARNING | CHANNEL_CRITICAL_FAULT);							
						break;
				}
		}
		if(!(CHANNELS[i].Channel_General_Status & CHANNEL_DETECTED))
			CHANNELS[i].Channel_General_Status |= CHANNEL_CRITICAL_FAULT;
		CHANNEL_cmd(i, ENABLE, DISABLE, DISABLE);
	}	
}
//END CHANNEL_Initial_Test_All

/**
  * @brief  Active l'un des canaux (complétement ou partiellement)
	* @param  CHANNEL_ID 		-> Le numérot du canal 
	* @param  POWER_state 	-> Alimentation génèrale du canal (ENABLE/DISABLE)
	* @param  HV_state 			-> Convertisseur haute tension (ENABLE/DISABLE) 		(inutile si POWER_state n'est pas ENABLE)
	* @param  OUTPUT_state 	-> Relais de sortie (ENABLE/DISABLE)								(inutile si POWER_state et HV_state ne sont pas ENABLE)
  */
void 			CHANNEL_cmd(uint8_t CHANNEL_ID, FunctionalState POWER_state, FunctionalState HV_state, FunctionalState OUTPUT_state){
	if(POWER_state==DISABLE){
		CHANNELS[CHANNEL_ID].CHANNEL_EN_port->ODR	&=~CHANNELS[CHANNEL_ID].CHANNEL_EN_pin;
		CHANNELS[CHANNEL_ID].Channel_General_Status &=~CHANNEL_EN;
	}else{
		CHANNELS[CHANNEL_ID].CHANNEL_EN_port->ODR	|= CHANNELS[CHANNEL_ID].CHANNEL_EN_pin;
		CHANNELS[CHANNEL_ID].Channel_General_Status |= CHANNEL_EN;
	}
	
	if(HV_state==DISABLE){
		#ifdef PROTO_BOARD
			CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_port->ODR	|= CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_pin;
		#else
			CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_port->ODR	&=~CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_pin;
		#endif
		CHANNELS[CHANNEL_ID].Channel_General_Status &=~CHANNEL_HV_EN;
	}else{
		if(!(CHANNELS[CHANNEL_ID].Channel_General_Status & CHANNEL_CRITICAL_FAULT)){	//Si une erreur critique est détéctée lors du test du cannal la haute tension ne peut pas s'activer
			#ifdef PROTO_BOARD
				CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_port->ODR	&=~CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_pin;
			#else
				CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_port->ODR	|= CHANNELS[CHANNEL_ID].CHANNEL_HV_EN_pin;
			#endif	
			CHANNELS[CHANNEL_ID].Channel_General_Status |= CHANNEL_HV_EN;
		}
	}
	
	if(OUTPUT_state==DISABLE){
		CHANNELS[CHANNEL_ID].CHANNEL_OUT_EN_port->ODR	&=~CHANNELS[CHANNEL_ID].CHANNEL_OUT_EN_pin;
		CHANNELS[CHANNEL_ID].Channel_General_Status &=~CHANNEL_OUT_EN;
	}else{
		if(!(CHANNELS[CHANNEL_ID].Channel_General_Status & CHANNEL_CRITICAL_FAULT)){	//Si une erreur critique est détéctée lors du test du cannal la haute tension ne peut pas s'activer
			CHANNELS[CHANNEL_ID].CHANNEL_OUT_EN_port->ODR	|= CHANNELS[CHANNEL_ID].CHANNEL_OUT_EN_pin;
			CHANNELS[CHANNEL_ID].Channel_General_Status |= CHANNEL_OUT_EN;
		}
	}
}
//END CHANNEL_cmd

/**
  * @brief  Message de test (à ne pas utiliser seulement prévu pour le débogage)
	* @param  CHANNEL_ID 		-> Le numérot du canal
  */
void			CHANNEL_debug(uint8_t CHANNEL_ID){
	uint8_t CCR=0;
	uint8_t i;
	
	GPIOD->ODR = CHANNELS[CHANNEL_ID].UART_MUX_pin;
	CurrentlyAddressedChannel = CHANNEL_ID;
	
	privat_UART_reset_Buffer();
	if(txBufferID)	txDataBuffer1[txBufferCnt] = MSG_TYPE_DEBUG;
	else						txDataBuffer0[txBufferCnt] = MSG_TYPE_DEBUG;
	txBufferCnt++;

	//Dummy Data
	privat_UART_add_7BitChar_To_TxBuffer(0x01);
	
	//Calcul le byte de vérification d'erreur
	if(txBufferID){
		for(i=0;i<=1;i++){
			CCR ^= txDataBuffer1[i];
		}		
	}else{
		for(i=0;i<=1;i++){
			CCR ^= txDataBuffer0[i];
		}
	}

	privat_UART_add_7BitChar_To_TxBuffer(CCR);	
	privat_UART_send_buffer();
}
//END CHANNEL_debug

/**
* @brief  Message d'initialisation et de test du cannal. Demande au cannal adressé de renvoyer les données suivantes :
	*					- Message ID (MSG_TYPE_GET_STATUS uint8_t)
	*					-	Message signature (CHANNEL_ID uint7_t)
  * 				- Version du software (uint7_t)
	*					-	Channel status register (uint32_t (5*7bit))
	*					-	Voltage rail positif (float (5*7bit))
	*					-	Voltage rail negatif (float (5*7bit))
	*					- CCR (7bit)
	* @param  CHANNEL_ID 		-> Le numérot du canal
  */
void			CHANNEL_get_full_status(uint8_t CHANNEL_ID){
	uint8_t CCR=0;
	uint8_t i;
	
	GPIOD->ODR = CHANNELS[CHANNEL_ID].UART_MUX_pin;
	CurrentlyAddressedChannel = CHANNEL_ID;
	
	privat_UART_reset_Buffer();
	if(txBufferID)	txDataBuffer1[txBufferCnt] = MSG_TYPE_GET_STATUS;
	else						txDataBuffer0[txBufferCnt] = MSG_TYPE_GET_STATUS;
	txBufferCnt++;

	//Identifiant pour la réponse 
	// - Afin d'être sûr que les données reçues correspondent bien à la réponse du cannal interogé et pas à des données déjà présentes
	//	 pour une raison quelconque dans le buffer de récéption on envois une signature que le cannal inclut dans sa réponse 
	//   (en l'occurence il s'agit de l'ID du cannal que ce dernier ne connait à priori pas car les cartes peuvent être montées dans n'importe quel slote)
	privat_UART_add_7BitChar_To_TxBuffer(CHANNEL_ID);
	
	//Calcul le byte de vérification d'erreur
	if(txBufferID){
		for(i=0;i<=1;i++){
			CCR ^= txDataBuffer1[i];
		}
	}else{
		for(i=0;i<=1;i++){
			CCR ^= txDataBuffer0[i];
		}
	}
	privat_UART_add_7BitChar_To_TxBuffer(CCR);
	
	//Lecture du buffer de reception afin de purger d'éventuelles donnée résiduelles qui pourraient être confondues avec la réponse attendue 
	CHANNEL_UART_rx_handler();
	//Envoie de la requète
	privat_UART_send_buffer();
	
	//Attente de la réponse	(20ms timeout)
	ChannelComStatus &=~LAST_RX_FRAME_OK;
	ChannelComStatus &=~LAST_RX_FRAME_FAULT;
	
	CHANNELS[CHANNEL_ID].Channel_General_Status &=~CHANNEL_COMMUNICATION_FAULT;
	CHANNELS[CHANNEL_ID].Channel_General_Status &=~CHANNEL_NOT_RESPONDING;
	CHANNELS[CHANNEL_ID].Channel_General_Status &=~CHANNEL_NOT_RESPONDING;	
	
	for(i=0;i<=200;i++){
		DELAY_1000US;
		CHANNEL_UART_rx_handler();
		if(ChannelComStatus & LAST_RX_FRAME_OK){
			CHANNELS[CHANNEL_ID].Channel_General_Status |= CHANNEL_DETECTED;
			break;
		}else if(ChannelComStatus & LAST_RX_FRAME_FAULT){
			CHANNELS[CHANNEL_ID].Channel_General_Status |= CHANNEL_COMMUNICATION_FAULT;
			break;
		}
	}
	
	if(i>=200){
		CHANNELS[CHANNEL_ID].Channel_General_Status |= CHANNEL_NOT_RESPONDING;
	}
	
}
//END CHANNEL_get_status

/**
  * @brief  Configure tt les paramètres de stimulation d'un canal
	* @param  CHANNEL_ID 		-> Le numérot du canal 
	* @param  ...
	* @return 0 si le canal n'est pas addressable
  */
uint32_t	CHANNEL_Set_Single_Channel_All_Param(uint8_t CHANNEL_ID, uint32_t t1, uint32_t t2, uint32_t t3, uint32_t t4, uint8_t Nb, float I){
	uint8_t CCR=0;
	uint8_t i;
	
	if( (CHANNELS[CHANNEL_ID].Channel_General_Status&(CHANNEL_DETECTED|CHANNEL_EN)) == (CHANNEL_DETECTED|CHANNEL_EN)){	//Donnée envoyée au canal seulement si il est détécté est actif
		GPIOD->ODR = CHANNELS[CHANNEL_ID].UART_MUX_pin;
		CurrentlyAddressedChannel = CHANNEL_ID;
		
		privat_UART_reset_Buffer();
		
		if(txBufferID)	txDataBuffer1[txBufferCnt] = MSG_TYPE_SET_ALL_CHAN_PARAM;
		else						txDataBuffer0[txBufferCnt] = MSG_TYPE_SET_ALL_CHAN_PARAM;
		
		txBufferCnt++;
		
		privat_UART_add_uint32_To_TxBuffer(t1);
		privat_UART_add_uint32_To_TxBuffer(t2);
		privat_UART_add_uint32_To_TxBuffer(t3);
		privat_UART_add_uint32_To_TxBuffer(t4);
		privat_UART_add_7BitChar_To_TxBuffer(Nb);
		privat_UART_add_float_To_TxBuffer(I);
		
		//Calcul le byte de vérification d'erreur
		if(txBufferID){
			for(i=0;i<=26;i++){
				CCR ^= txDataBuffer1[i];
			}		
		}else{
			for(i=0;i<=26;i++){
				CCR ^= txDataBuffer0[i];
			}
		}

		privat_UART_add_7BitChar_To_TxBuffer(CCR);	
		privat_UART_send_buffer();
		return 1;
	}else{
		return 0;
	}
}
//END CHANNEL_Set_Single_Channel_All_Param


/**
  * @brief  Configure tt les paramètres de stimulation d'un canal
	* @param  CHANNEL_ID 		-> Le numérot du canal 
	* @param  ...
	* @return 0 si le canal n'est pas addressable
  */
uint32_t	CHANNEL_Set_Single_Channel_All_Param_v2(uint8_t CHANNEL_ID, uint32_t t1, uint32_t t2, uint32_t t3, uint32_t t4, uint8_t Nb, float I, uint8_t mode){
	uint8_t CCR=0;
	uint8_t i;
	
	if( (CHANNELS[CHANNEL_ID].Channel_General_Status&(CHANNEL_DETECTED|CHANNEL_EN)) == (CHANNEL_DETECTED|CHANNEL_EN)){	//Donnée envoyée au canal seulement si il est détécté est actif
		GPIOD->ODR = CHANNELS[CHANNEL_ID].UART_MUX_pin;
		CurrentlyAddressedChannel = CHANNEL_ID;
		
		privat_UART_reset_Buffer();
		
		if(txBufferID)	txDataBuffer1[txBufferCnt] = MSG_TYPE_SET_ALL_CHAN_PARAM;
		else			txDataBuffer0[txBufferCnt] = MSG_TYPE_SET_ALL_CHAN_PARAM;
		
		txBufferCnt++;
		
		privat_UART_add_uint32_To_TxBuffer(t1);
		privat_UART_add_uint32_To_TxBuffer(t2);
		privat_UART_add_uint32_To_TxBuffer(t3);
		privat_UART_add_uint32_To_TxBuffer(t4);
		privat_UART_add_7BitChar_To_TxBuffer(Nb);
		privat_UART_add_float_To_TxBuffer(I);
		privat_UART_add_7BitChar_To_TxBuffer(mode);
		//Calcul le byte de vérification d'erreur
		if(txBufferID){
			for(i=0;i<=27;i++){
				CCR ^= txDataBuffer1[i];
			}		
		}else{
			for(i=0;i<=27;i++){
				CCR ^= txDataBuffer0[i];
			}
		}

		privat_UART_add_7BitChar_To_TxBuffer(CCR);	
		privat_UART_send_buffer();
		return 1;
	}else{
		return 0;
	}
}
//END CHANNEL_Set_Single_Channel_All_Param_v2

/**
  * @brief  Configure un paramètre de stimulation d'un canal
	* @param  CHANNEL_ID 		-> Le numérot du canal
	* @param  VAR_ID 				1->t1,2->t2,3->t3,4->t4,5->Nb,6->I
	* @param  DATA
	* @return 0 si le canal n'est pas addressable
  */
uint32_t	CHANNEL_Set_Single_Channel_Single_Param(uint8_t CHANNEL_ID, uint8_t VAR_ID, uint32_t DATA){
	uint8_t CCR=0;
	uint8_t i;
	
	if( (CHANNELS[CHANNEL_ID].Channel_General_Status&(CHANNEL_DETECTED|CHANNEL_EN)) == (CHANNEL_DETECTED|CHANNEL_EN)){
		GPIOD->ODR = CHANNELS[CHANNEL_ID].UART_MUX_pin;
		CurrentlyAddressedChannel = CHANNEL_ID;
		
		privat_UART_reset_Buffer();
		
		if(txBufferID)	txDataBuffer1[txBufferCnt] = MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM;
		else						txDataBuffer0[txBufferCnt] = MSG_TYPE_SET_SINGLE_CHAN_SINGLE_PARAM;
		
		txBufferCnt++;
		
		privat_UART_add_7BitChar_To_TxBuffer(VAR_ID);
		privat_UART_add_uint32_To_TxBuffer(DATA);
		
		//Calcul le byte de vérification d'erreur
		if(txBufferID){
			for(i=0;i<=6;i++){
				CCR ^= txDataBuffer1[i];
			}		
		}else{
			for(i=0;i<=6;i++){
				CCR ^= txDataBuffer0[i];
			}
		}

		privat_UART_add_7BitChar_To_TxBuffer(CCR);	
		privat_UART_send_buffer();
		return 1;
	}else{
		return 0;
	}
}
//END CHANNEL_Set_Single_Channel_Single_Param

/**
  * @brief  Init RX
  * @param  rxData
  * @retval None
  */
void 			CHANNEL_UART_rx_init(void){
	HAL_UART_Receive_DMA(&huart3, rxDataBuffer, RX_BUFFER_SIZE);
}
//END USART_rx_init

/**
  * @brief  UART channel low level data handling 
	*					Should be called periodicaly to check if there are new datas in "rxDataBuffer" and process them
  * @param  None
  * @retval None, the function call directly 'USART_packet_handler(..)' to process recieved data/request
  */
void 			CHANNEL_UART_rx_handler(void){
	static uint8_t	rxBufferID=0, FrameStartID=0, ByteCounter=0;
	uint8_t 				rxBufferTop,	dataTmp;
	
	rxBufferTop = (uint8_t)(RX_BUFFER_SIZE - hdma_usart3_rx.Instance->CNDTR);
	//DebugVar2 = rxBufferTop;
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
//END CHANNEL_UART_rx_handler

/**
  * @brief  Dummy, force rx_handler to ignore current packet (use when reseting uart after crash)
  */
void 			CHANNEL_UART_RST_rx_handler(void){
	PacketRxState = IDLE;
}
//END CHANNEL_UART_RST_rx_handler





/**
  * @brief  USART com. channel high level data handling
  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (FRAME_START) of the recieved Frame in the rxDataBuffer
	*					 - FrameSize 		: 	Should be equal to 7
  * @retval None
  */
static void		privat_Debug_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	DebugVar0 		= privat_ConvBits2float(FrameStartID+1);
	DebugVar1 		= privat_ConvBits2float(FrameStartID+6);
	LED0_GPIO_Port->ODR 						^= LED0_Pin;
}
//END privat_Debug_packet_handler

/**
  * @brief  Fonction gérant les paquets contenant le status renvoyé par les canaux (en réponse à "CHANNEL_get_status")
*					Le contenu attendu du message est le suivant (1+1+1+5+5+5+1 = 19 x 7bits): 
	*					- Message ID (MSG_TYPE_GET_STATUS uint8_t)
	*					-	Message signature (CHANNEL_ID uint7_t)
  * 				- Version du software (uint7_t)
	*					-	Channel status register (uint32_t (5*7bit))
	*					-	Voltage rail positif (float (5*7bit))
	*					-	Voltage rail negatif (float (5*7bit))
	*					- CCR (7bit)
  * @param  Variable
	* 				 - FrameStartID : 	ID of the first byte (FRAME_START) of the recieved Frame in the rxDataBuffer
  * @retval None
  */
static void		privat_Status_packet_handler(uint8_t FrameStartID, uint8_t FrameSize){
	uint8_t CCR	= 0;
	uint8_t i;
	
	// Vérifie la longueur du message reçu et l'origine
	if((FrameSize!=19) || (rxDataBuffer[(uint8_t)(FrameStartID+1)]!=CurrentlyAddressedChannel)){
		ChannelComStatus |= LAST_RX_FRAME_FAULT;
		return;
	}
	
	// Calcul du CCR
	for(i=0;i<=FrameSize-2;i++){
		CCR ^= rxDataBuffer[(uint8_t)(FrameStartID+i)];
	}
	
	if((CCR&0x7F)!=rxDataBuffer[(uint8_t)(FrameStartID+FrameSize-1)]){
		ChannelComStatus |= LAST_RX_FRAME_FAULT;
		return;
	}
	
	ChannelComStatus |= LAST_RX_FRAME_OK;

	CHANNELS[CurrentlyAddressedChannel].Channel_Software_version = rxDataBuffer[(uint8_t)(FrameStartID+2)];
	CHANNELS[CurrentlyAddressedChannel].Channel_Status_Reg 	= privat_ConvBits2uint32((uint8_t)(FrameStartID+3));
	CHANNELS[CurrentlyAddressedChannel].Channel_Voltage_Pos = privat_ConvBits2float((uint8_t)(FrameStartID+8));
	CHANNELS[CurrentlyAddressedChannel].Channel_Voltage_Neg = privat_ConvBits2float((uint8_t)(FrameStartID+13));
}
//END privat_Status_packet_handler



/**
  * @brief  Reconstruit un float à partir de 5 charactères (7 bites utiles) 
  * @param  Variable
	* 				 - FloatByteStartID : 	ID of the first byte of the float
  * @retval None
  */
static float	privat_ConvBits2float(uint8_t FloatByteStartID){
	uint32_t TMP = 0x00000000;
	TMP = (rxDataBuffer[FloatByteStartID]<<25) | (rxDataBuffer[(uint8_t)(FloatByteStartID+1)]<<18) | (rxDataBuffer[(uint8_t)(FloatByteStartID+2)]<<11) | (rxDataBuffer[(uint8_t)(FloatByteStartID+3)]<<4) | (rxDataBuffer[(uint8_t)(FloatByteStartID+4)]>>3);
	return *((float*)&TMP);
}
//END privat_ConvBits2float

/**
  * @brief  Reconstruit un uint32 à partir de 5 charactères (7 bites utiles) 
  * @param  Variable
	* 				 - Uint32ByteStartID : 	ID of the first byte of the float
  * @retval None
  */
static uint32_t	privat_ConvBits2uint32(uint8_t Uint32ByteStartID){
	uint32_t TMP = 0x00000000;
	TMP = (rxDataBuffer[Uint32ByteStartID]<<25) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+1)]<<18) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+2)]<<11) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+3)]<<4) | (rxDataBuffer[(uint8_t)(Uint32ByteStartID+4)]>>3);
	return TMP;
}
//END privat_ConvBits2uint32

/**
  * @brief  Ajoute 7bit (uint8_t) avec 7 bit utile au buffer d'envoi
  */
static void		privat_UART_add_7BitChar_To_TxBuffer(uint8_t DATA){

	if(txBufferID){
		txDataBuffer1[txBufferCnt] = DATA & 0x7F;
	}else{
		txDataBuffer0[txBufferCnt] = DATA & 0x7F;
	}
	txBufferCnt++;	
}
//END privat_UART_add_7BitChar_To_TxBuffer

/**
  * @brief  Ajoute un uint32_t au buffer d'envoi
  */
static void		privat_UART_add_uint32_To_TxBuffer(uint32_t DATA){

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
//END privat_UART_add_uint32_To_TxBuffer

/**
  * @brief  Ajoute une variable de type "float" au buffer d'envoie
  */
static void		privat_UART_add_float_To_TxBuffer(float DATA){
	uint32_t TMP=*((uint32_t*)&	DATA);

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
//END privat_UART_add_float_To_TxBuffer

/**
  * @brief  Vide le buffer d'envoie 
	* 				Utile dans le cas d'une communication assychrone :
	*						Si une version plus réssente des donnés déjà présentes dans le buffer d'envoie existe alors on
	*						vide le buffer et on met les données les plus réssentes à la place
  */
static void		privat_UART_reset_Buffer(void){
	txBufferCnt = 0;
}
//END privat_UART_reset_Buffer

/**
  * @brief  Envois le contenu du buffer d'envois en cours d'utilisation via UART et passe au second buffer
  */
static void		privat_UART_send_buffer(void){
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
//END privat_UART_send_buffer







