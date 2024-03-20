#ifndef __CHANNEL_COM_FUNCTION_H
#define __CHANNEL_COM_FUNCTION_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Include */
#include "main.h"
#include <stdint.h>
#include "stm32f3xx_hal.h"




/* Prototype */
void CHANNEL_Initial_Test_All(void);
void CHANNEL_cmd(uint8_t CHANNEL_ID, FunctionalState POWER_state, FunctionalState HV_state, FunctionalState OUTPUT_state);
void CHANNEL_debug(uint8_t CHANNEL_ID);
void CHANNEL_get_full_status(uint8_t CHANNEL_ID);
uint32_t CHANNEL_Set_Single_Channel_All_Param(uint8_t CHANNEL_ID, uint32_t t1, uint32_t t2, uint32_t t3, uint32_t t4, uint8_t Nb, float I);	 
uint32_t CHANNEL_Set_Single_Channel_All_Param_v2(uint8_t CHANNEL_ID, uint32_t t1, uint32_t t2, uint32_t t3, uint32_t t4, uint8_t Nb, float I, uint8_t mode);
uint32_t CHANNEL_Set_Single_Channel_Single_Param(uint8_t CHANNEL_ID, uint8_t VAR_ID, uint32_t DATA);	 
	
void CHANNEL_UART_rx_init(void);
void CHANNEL_UART_rx_handler(void);
void CHANNEL_UART_RST_rx_handler(void);




#ifdef __cplusplus
}
#endif

#endif 
