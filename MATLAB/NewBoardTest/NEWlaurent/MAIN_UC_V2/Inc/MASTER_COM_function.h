#ifndef __MASTER_COM_FUNCTION_H
#define __MASTER_COM_FUNCTION_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Include */
#include "main.h"
#include <stdint.h>
#include "stm32f3xx_hal.h"




/* Prototype */
void MASTER_UART_rx_init(void);
void MASTER_UART_rx_handler(void);
void MASTER_UART_RST_rx_handler(void);




#ifdef __cplusplus
}
#endif

#endif 
