#ifndef __USART_FUNCTION_H
#define __USART_FUNCTION_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Include */
#include "main.h"
#include <stdint.h>
#include "stm32f1xx_hal.h"



/* Prototype */
void USART_rx_init(UART_HandleTypeDef *huart);
void USART_rx_handler(void);
void USART_RST_rx_handler(void);
void USART_add_7BitChar_To_TxBuffer(uint8_t DATA);
void USART_add_uint32_To_TxBuffer(uint32_t DATA);
void USART_add_float_To_TxBuffer(float DATA);
//void USART_send_buffer(UART_HandleTypeDef *huart);
void USART_send_buffer(void);
void USART_reset_Buffer(void);

/* Private prototype in *.c file */
//void USART_RTP_mode_packet_handler(uint8_t FrameStartID, uint8_t FrameSize); 


#ifdef __cplusplus
}
#endif

#endif 
