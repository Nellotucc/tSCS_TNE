// ###############################################################################################################
/*
	Pulses du point de vue de l'utilisateur :
	
      |<----------  Nb répétition  --------->|                       |<---------- Nb répétition  ---------->|    
    
       -----                   -----                                  -----                   -----                         -
      |  +  |                 |  +  |                                |  +  |                 |  +  |                        |
   ---       --       --------       --       ---------/.../---------       --       --------       --       ----------...  |  2 x I_pulse ~ mA    
               |  -  |                 |  -  |                                |  -  |                 |  -  |               |
                -----                   -----                                  -----                   -----                -

      | t1  |t2|  t1 |   t3   | t1  |t2|  t1 |           t4          | t1  |t2|  t1 |   t3   | t1  |t2|  t1 |     t4   ...
      |<-------------------------   t4*    ------------------------->|<-------------------------   t4*    -------------...
	  

 *NOTE 1    Il y a un seuil minimum de signal (du DAC) qui va effectivement engendrer une valeure de sortie (voir rapport pour explication)
            De plus à cause des différences entre les tensions de seuils des MOSFET canal P et N la valeure n'est pas identique dans les deux sens
 *NOTE 2    L'overdrive (underdrive) consiste en une impulsion de durée et d'amplitude fixe ajoutée avant et après chaque pulse afin de vaincre 
            un phénomène d'hystérèse dans la chaine d'amplification (voir rapport pour explication). 
            Sans celà les pulses de faibles amplitudes tendent à être plus courts que désiré et pas symétriques 
            En principe la valeure devrait être identique dans les deux sens 
 *NOTE 3    Une durrée du "DEADTIME" plus petite que "DEADTIME_MIN_DURATION_US" donnera un "DEADTIME" égal à "2*OVERDRIVE_DURATION_US" 
            Donc concrétement les valeurs possible pour le "DEADTIME" sont : 
            {2*OVERDRIVE_DURATION_US, DEADTIME_MIN_DURATION_US, DEADTIME_MIN_DURATION_US+1, DEADTIME_MIN_DURATION_US+2, ... , DEADTIME_MAX_DURATION_US} = {20,30,31,32,...,350}
 *NOTE 4    Les valeurs stoquées dans cette structure ne sont pas exactement en us (à cause de l'offset et des overdrives) par contre la mise à jour des valeurs
            en utilisant les fonctions Channel_Set_#### prènent en argument des valeurs en us et font la conversion
*/
// ###############################################################################################################

#include "Channel_function.h"
#include "stm32f1xx_hal.h"
#include "main.h"	 
#include <stdbool.h>

//#define dacVal2mA 8.69f //Conversion entre incréments du DAC et le courant de sortie (valeur pour la carte proto) (1[mA]->14[mV] shunt -> 7[mV] adc -> 4096[inc]*7[mV/mA]/3300[mV]=8.69[inc/mA])
#define dacVal2mA 18.62f  //Conversion entre incréments du DAC et le courant de sortie  (1[mA]->15[mV] shunt ->15[mV] adc -> 4096[inc]*15[mV/mA]/3300[mV]=18.62[inc/mA])

//Paramètres d'offset (voir *NOTE 1)
#define ZERO_CURRENT_HIGH_TH_MA                  3.5f                                
#define ZERO_CURRENT_HIGH_TH_DAC_INC             ((uint32_t)(ZERO_CURRENT_HIGH_TH_MA * dacVal2mA))
#define ZERO_CURRENT_LOW_TH_MA                   2.3f
#define ZERO_CURRENT_LOW_TH_DAC_INC              ((uint32_t)(ZERO_CURRENT_LOW_TH_MA * dacVal2mA))

//Paramètres de l'overdrive (voir *NOTE 2)
#define OVERDRIVE_DURATION_US                    15          //Durée de l'overdrive (underdrive) ~ us (!!! MUST BE BIGGER THAN TIMING_OFFSET_US+3)
#define OVERDRIVE_HIGH_CURRENT_MA                14.5f       //Intensité de l'overdrive positif
#define OVERDRIVE_HIGH_CURRENT_DAC_INC           ((uint32_t)(OVERDRIVE_HIGH_CURRENT_MA * dacVal2mA)) 
#define OVERDRIVE_LOW_CURRENT_MA                 11.0f       //Intensité de l'overdrive negatif
#define OVERDRIVE_LOW_CURRENT_DAC_INC            ((uint32_t)(OVERDRIVE_LOW_CURRENT_MA * dacVal2mA))

//Limite des durrées des diférentes phase de la stimulation (voir schéma)
#define TIMING_OFFSET_US                         9                        //Correction des periodes ~ us (utilisé pour compensé le fait qu'on arrête le timer à chaque fois qu'on execute "Channel_UpdateOutput" ... pas trés propre voir pour modifier?)
#define PULSE_MIN_DURATION_US                    TIMING_OFFSET_US+10      //t1 min value ~ us
#define PULSE_MAX_DURATION_US                    2000                      //t1 max value ~ us
#define DEADTIME_MIN_DURATION_US                 TIMING_OFFSET_US+10      //t2 min value ~ us (*voir NOTE 3)
#define DEADTIME_MAX_DURATION_US                 350                      //t2 max value ~ us
#define INTERPULSE_MIN_DURATION_US               TIMING_OFFSET_US+10      //t3 min value ~ us
#define INTERPULSE_MAX_DURATION_US               50000                     //t3 max value ~ us
#define INTERFRAME_MIN_DURATION_US               5000                     //t4 min value ~ us    !!! il s'agit bien de t4 et non t4* (même si en principe t4 =~ t4*) This value should be big enough for the supervision task to be perform
#define INTERFRAME_MAX_DURATION_US               10000000                    //t4* max value ~ us  !!! il s'agit bien de t4* et non t4 (même si en principe t4 =~ t4*)
#define MIN_PULSE_REPETITION                     1                        //Nombre min d'impulsions sucessives dans une frame
#define MAX_PULSE_REPETITION                     10                       //Nombre max d'impulsions sucessives dans une frame
#define MAX_CURRENT_MA                           150.0f                   //Intensité max du courant ~ mA


#define ENABLE_PULSE             		(1<<0)
#define ENABLE_CONTINUOUS_PULSE_MODE  	(1<<1)


typedef enum{ 
    INTER_PULSE_IDLE,			//0V
	INTER_FRAME_IDLE,			//0V
	HIGH_PULSE_OVERDRIVE,	
	HIGH_PUSLE,  				//Pulse positife
	HIGH_PULSE_UNDERDRIVE,
	DEATTIME,					//Temps mort entre pulse positife et négatife
	LOW_PULSE_OVERDRIVE,
	LOW_PUSLE, 			  		//Pulse négatif
	LOW_PULSE_UNDERDRIVE
}ChannelStateEnum;
//END typedef

//Paramètres des signaux de stimulation (voir *NOTE 4)
typedef struct{
	uint32_t t1;					//Durée d'un pulse (t1) unité éq. 'us' mais sans compter les offsets
	uint32_t t2;					//Durée entre le pulse haut et bas (t2) unité éq. 'us' mais sans compter les offsets
	uint32_t t3;					//Durée entre la fin d'un pulse low et du prochain pulse high (t3) unité éq. 'us' mais sans compter les offsets
	uint32_t t4;					//Durée entre les frame unité éq. '10*us' mais sans compter  les offsets
	uint32_t t4_multiplier;			//Multiplicateur de t4 pour avoir des interframes > que 65535 TIC du timer7
	uint32_t pulseRepetitions;		//Nombre de pulse par frame
	uint32_t pulseLevel_DACinc;  	//Intensité des pulses en incrément du DAC (DACinc = mA * dacVal2mA)
	uint32_t status;
}ChannelParamTypeDef;
//END typedef

bool 	newPulseTrigger = false;	

extern DAC_HandleTypeDef 	hdac;
extern volatile uint32_t	MainStatus;
	

ChannelParamTypeDef ChannelParam 	= {
	100,	//t1
	20,		//t2
	300,	//t3
	10000,	//t4
	1,		//t4 mult
	0,		//N
	0,		//I
	ENABLE_CONTINUOUS_PULSE_MODE
};

ChannelParamTypeDef ChannelParamNew = {
	100,	//t1
	20,		//t2
	300,	//t3
	10000,	//t4
	1,		//t4 mult
	0,		//N
	0,		//I
	ENABLE_CONTINUOUS_PULSE_MODE
};



/**
  * @brief  Met à jour l'état de la sortie du canal 
  * @param  
  * @retval None
  */
void Channel_UpdateOutput(void){
	static ChannelStateEnum currentState = INTER_FRAME_IDLE;
	static uint32_t PulseCounter = 0;
	static uint32_t t4_multiplierCounter = 0;
		
	switch(currentState){
		case INTER_FRAME_IDLE:
			    t4_multiplierCounter++;
				if(t4_multiplierCounter>=ChannelParam.t4_multiplier){
					t4_multiplierCounter = 0;
					if((ChannelParam.status & ENABLE_CONTINUOUS_PULSE_MODE) || newPulseTrigger){
						newPulseTrigger = false;
						TIM6->CNT 	   = 0;
						TIM6->ARR 	   = ((uint32_t)OVERDRIVE_DURATION_US-TIMING_OFFSET_US);
						if(ChannelParam.status & ENABLE_PULSE)
							HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) - OVERDRIVE_HIGH_CURRENT_DAC_INC - ZERO_CURRENT_HIGH_TH_DAC_INC);
						TIM6->CR1     |=(TIM_CR1_CEN);
						PulseCounter++;
						currentState   = HIGH_PULSE_OVERDRIVE;
					}else{
						TIM7->CR1     |=(TIM_CR1_CEN);
						ChannelParam   = ChannelParamNew; 					//Mise à jour éventuelle des paramètres
						MainStatus	  |= RUN_CYCLIC_SUPERVISION_TASK;		//Signal que la frame est finie et qu'il y a du temps pour executer les fonctions secondaires
						//currentState   = INTER_FRAME_IDLE;
					}
				}else{
					TIM7->CR1     |=(TIM_CR1_CEN);
					ChannelParam   = ChannelParamNew; //Mise à jour éventuelle des paramètres
					MainStatus	  |= RUN_CYCLIC_SUPERVISION_TASK;		//Signal que la frame est finie et qu'il y a du temps pour executer les fonctions secondaires
				}
				break;
				
		case INTER_PULSE_IDLE:
				TIM6->CNT 	   = 0;
				TIM6->ARR 	   = ((uint32_t)OVERDRIVE_DURATION_US-TIMING_OFFSET_US);
				if(ChannelParam.status & ENABLE_PULSE)
					HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) - OVERDRIVE_HIGH_CURRENT_DAC_INC - ZERO_CURRENT_HIGH_TH_DAC_INC);
				TIM6->CR1     |=(TIM_CR1_CEN);
				currentState   = HIGH_PULSE_OVERDRIVE;
				PulseCounter++;
				break;
				
		case HIGH_PULSE_OVERDRIVE:
				TIM6->CNT 	   = 0;
				TIM6->ARR 	   = ChannelParam.t1;
				if(ChannelParam.status & ENABLE_PULSE)
					HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) - ChannelParam.pulseLevel_DACinc - ZERO_CURRENT_HIGH_TH_DAC_INC);
				TIM6->CR1     |=(TIM_CR1_CEN);
				currentState   = HIGH_PUSLE;
				break;
				
		case HIGH_PUSLE:
				TIM6->CNT 		 = 0;
				TIM6->ARR 		 = ((uint32_t)OVERDRIVE_DURATION_US-TIMING_OFFSET_US); //(UNDERDRIVE)
				if(ChannelParam.status & ENABLE_PULSE)
					HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) + OVERDRIVE_HIGH_CURRENT_DAC_INC + ZERO_CURRENT_HIGH_TH_DAC_INC);
				TIM6->CR1     |=(TIM_CR1_CEN);
				currentState 	 = HIGH_PULSE_UNDERDRIVE;
				break;
				
		case HIGH_PULSE_UNDERDRIVE:
				HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11));
				TIM6->CNT 		 = 0;
				if(ChannelParam.t2>0){ //Si temps mort entre pulse haut et bas non nul
					TIM6->ARR 		 = ChannelParam.t2;			
					currentState 	 = DEATTIME;
				}else{ //Si temps mort nul on passe direct au pulse négatif
					TIM6->ARR 		 = ((uint32_t)OVERDRIVE_DURATION_US-TIMING_OFFSET_US);
					if(ChannelParam.status & ENABLE_PULSE)
						HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) + OVERDRIVE_LOW_CURRENT_DAC_INC + ZERO_CURRENT_LOW_TH_DAC_INC);
					currentState 	 = LOW_PULSE_OVERDRIVE;					
				}
				TIM6->CR1     |=(TIM_CR1_CEN);
				break;
				
		case DEATTIME:
				TIM6->CNT 		 = 0;
				TIM6->ARR 		 = ((uint32_t)OVERDRIVE_DURATION_US-TIMING_OFFSET_US);
				if(ChannelParam.status & ENABLE_PULSE)
					HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) + OVERDRIVE_LOW_CURRENT_DAC_INC + ZERO_CURRENT_LOW_TH_DAC_INC);
				TIM6->CR1     |=(TIM_CR1_CEN);
				currentState 	 = LOW_PULSE_OVERDRIVE;			
				break;
				
		case LOW_PULSE_OVERDRIVE:
				TIM6->CNT 		 = 0;
				TIM6->ARR 		 = ChannelParam.t1;
				if(ChannelParam.status & ENABLE_PULSE)
					HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) + ChannelParam.pulseLevel_DACinc + ZERO_CURRENT_LOW_TH_DAC_INC);
				TIM6->CR1     |=(TIM_CR1_CEN);
				currentState 	 = LOW_PUSLE;
				break;
				
		case LOW_PUSLE:	
				TIM6->CNT 		 = 0;
				TIM6->ARR 		 = ((uint32_t)OVERDRIVE_DURATION_US-TIMING_OFFSET_US); //(UNDERDRIVE)
				if(ChannelParam.status & ENABLE_PULSE)
					HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11) - OVERDRIVE_LOW_CURRENT_DAC_INC - ZERO_CURRENT_LOW_TH_DAC_INC);
				TIM6->CR1     |=(TIM_CR1_CEN);
				currentState 	 = LOW_PULSE_UNDERDRIVE;
				break;
				
		case LOW_PULSE_UNDERDRIVE:
				HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11));
				if(PulseCounter>=ChannelParam.pulseRepetitions){
					PulseCounter   = 0;
					TIM7->CNT 	   = 0;
					TIM7->ARR 	   = ChannelParam.t4;
					TIM7->CR1     |=(TIM_CR1_CEN);
					ChannelParam   = ChannelParamNew; //Mise à jour éventuelle des paramètres
					MainStatus	  |= RUN_CYCLIC_SUPERVISION_TASK;		//Signal que la frame est finie et qu'il y a du temps pour executer les fonctions secondaires
					currentState   = INTER_FRAME_IDLE;
				}else{
					TIM6->CNT 	   = 0;
					TIM6->ARR 	   = ChannelParam.t3;
					TIM6->CR1     |=(TIM_CR1_CEN);
					currentState   = INTER_PULSE_IDLE;				
				}
				break;
				
		default:
				currentState   = INTER_FRAME_IDLE;
				HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, (1<<11));
				break;
		}
}
//END UpdateOutput




/**
  * @brief  Change la largeur des impulsions
  * @param  PulseWidth_us en micro seconde
  * @retval None
  */
void Channel_SetPulseWidth(uint32_t PulseWidth_us){
	if(PulseWidth_us<PULSE_MIN_DURATION_US)
		PulseWidth_us = PULSE_MIN_DURATION_US;
	else if(PulseWidth_us>PULSE_MAX_DURATION_US)
		PulseWidth_us = PULSE_MAX_DURATION_US;
	
	ChannelParamNew.t1 = PulseWidth_us-TIMING_OFFSET_US;
}
//END Channel_SetPulseWidth




/**
  * @brief  Change la largeur du temps mort entre pulse positif et négatif
	*         
  * @param  DeadTimeWidth_us en micro seconde
  * @retval None
  */
void Channel_SetDeadTimeWidth(uint32_t DeadTimeWidth_us){
	int32_t tmp = DeadTimeWidth_us;
	tmp -= (2*OVERDRIVE_DURATION_US);
	
	if(tmp <= DEADTIME_MIN_DURATION_US){
		ChannelParamNew.t2 = 0;
		return;
	}
	
	if(tmp>DEADTIME_MAX_DURATION_US){
		tmp = DEADTIME_MAX_DURATION_US;	
	}
	
	ChannelParamNew.t2 = tmp - TIMING_OFFSET_US;
}
//END Channel_SetDeadTime




/**
  * @brief  Change la durée entre deux paires de pulses d'un même train d'impulsion
  * @param  InterPulseTimeWidth_us en micro seconde
  * @retval None
  */
void Channel_SetInterPulseTimeWidth(uint32_t InterPulseTimeWidth_us){
	if(InterPulseTimeWidth_us<INTERPULSE_MIN_DURATION_US)
		InterPulseTimeWidth_us = INTERPULSE_MIN_DURATION_US;
	else if(InterPulseTimeWidth_us>INTERPULSE_MAX_DURATION_US)
		InterPulseTimeWidth_us = INTERPULSE_MAX_DURATION_US;
	
	ChannelParamNew.t3 = InterPulseTimeWidth_us-TIMING_OFFSET_US;
}
//END Channel_SetInterPulseTimeWidth




/**
  * @brief  Change la durée entre deux train d'impulsions 
  * @param  InterFrameTimeWidth_us en micro seconde (t4* sur le chémat)
  * @retval None
  */
void Channel_SetInterFrameTimeWidth(uint32_t InterFrameTimeWidth_us){
	uint32_t FullFrameDuration_us = 0;
	
	FullFrameDuration_us = ChannelParam.pulseRepetitions * 2 *(ChannelParam.t1+TIMING_OFFSET_US);
	FullFrameDuration_us+= (ChannelParam.pulseRepetitions-1) *(ChannelParam.t3+TIMING_OFFSET_US);
	
	if(ChannelParam.t2)
		FullFrameDuration_us+= ChannelParam.pulseRepetitions * (ChannelParam.t2+TIMING_OFFSET_US);
	
	
	if(InterFrameTimeWidth_us>INTERFRAME_MAX_DURATION_US)	//Verifie que " t4* " pas trop grand (!!! il s'agit bien de " t4* " et non de " t4 ")
		InterFrameTimeWidth_us = INTERFRAME_MAX_DURATION_US;
	
	if(InterFrameTimeWidth_us>FullFrameDuration_us)
		InterFrameTimeWidth_us-=FullFrameDuration_us;
	else
		InterFrameTimeWidth_us=0;
	
	if(InterFrameTimeWidth_us<INTERFRAME_MIN_DURATION_US)	//Verifie que " t4 " pas trop petit (!!! il s'agit bien de " t4 " et non de " t4* ")
		InterFrameTimeWidth_us = INTERFRAME_MIN_DURATION_US;	
	
	ChannelParamNew.t4_multiplier = 1;
	while(InterFrameTimeWidth_us>65534){
		InterFrameTimeWidth_us = InterFrameTimeWidth_us/2;
		ChannelParamNew.t4_multiplier = ChannelParamNew.t4_multiplier*2;
	}
	
	
	ChannelParamNew.t4 = (InterFrameTimeWidth_us-TIMING_OFFSET_US);
}
//END Channel_SetInterFrameTimeWidth




/**
  * @brief  Change le nombre de pulse dans un train d'impulsion
  * @param  PulseRepetitionCnt en nombre de pair d'impulsion
  * @retval None
  */
void Channel_SetPulseRepetitionCnt(uint32_t PulseRepetitionCnt){
	if(PulseRepetitionCnt<MIN_PULSE_REPETITION)
		PulseRepetitionCnt = MIN_PULSE_REPETITION;
	else if(PulseRepetitionCnt>MAX_PULSE_REPETITION)
		PulseRepetitionCnt = MAX_PULSE_REPETITION;
	
	ChannelParamNew.pulseRepetitions = PulseRepetitionCnt;
}
//END Channel_SetPulseRepetitionCnt




/**
  * @brief  Change l'amplitude des pulses
  * @param  Amplitude en miliampère
  * @retval None
  */
void Channel_SetAmplitude(float Amplitude_mA){
	if(Amplitude_mA>MAX_CURRENT_MA)
		Amplitude_mA = MAX_CURRENT_MA;
	if(Amplitude_mA<=0){
		ChannelParamNew.pulseLevel_DACinc = 0;
		ChannelParamNew.status &=~ENABLE_PULSE;
	}else{
		ChannelParamNew.pulseLevel_DACinc = ((uint32_t)(Amplitude_mA * dacVal2mA));	
		ChannelParamNew.status	|= ENABLE_PULSE;
	}
}
//END Channel_SetAmplitude




/**
  * @brief  Select between "continuous mode" or "manual triggered mode"
  * @param  
  * @retval None
  */
void Channel_SetMode(uint32_t Mode){
	if(Mode == 1){ //Disable continuous mode
		ChannelParamNew.status &=~ ENABLE_CONTINUOUS_PULSE_MODE;
	}else{
		ChannelParamNew.status |= ENABLE_CONTINUOUS_PULSE_MODE;
	}
}
//END Channel_SetMode




/**
  * @brief  Trigger a new pulse (useless if continuous mode is enable)
  * @param  
  * @retval None
  */
void Channel_ManualPulseTrigger(void){
	newPulseTrigger = true;
}
//END Channel_ManualPulseTrigger
