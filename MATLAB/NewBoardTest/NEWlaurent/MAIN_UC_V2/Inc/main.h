/**
  ******************************************************************************
  * File Name          : main.h
  * Description        : This file contains the common defines of the application
  ******************************************************************************
  *
  * COPYRIGHT(c) 2024 STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *   1. Redistributions of source code must retain the above copyright notice,
  *      this list of conditions and the following disclaimer.
  *   2. Redistributions in binary form must reproduce the above copyright notice,
  *      this list of conditions and the following disclaimer in the documentation
  *      and/or other materials provided with the distribution.
  *   3. Neither the name of STMicroelectronics nor the names of its contributors
  *      may be used to endorse or promote products derived from this software
  *      without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H
  /* Includes ------------------------------------------------------------------*/

/* USER CODE BEGIN Includes */
#define PROTO_BOARD

#ifdef PROTO_BOARD
	#define PUSH_BUTTON_INPUT_Pin 				GPIO_PIN_4
	#define PUSH_BUTTON_INPUT_GPIO_Port 	GPIOC
	#define LED_Pin 											GPIO_PIN_6
	#define LED_GPIO_Port 								GPIOA
#else
	#define PUSH_BUTTON_INPUT_Pin 				GPIO_PIN_2
	#define PUSH_BUTTON_INPUT_GPIO_Port 	GPIOE	
#endif

/* USER CODE END Includes */

/* Private define ------------------------------------------------------------*/

#define PUSH_BUTTON_INPUT0_Pin GPIO_PIN_2
#define PUSH_BUTTON_INPUT0_GPIO_Port GPIOE
#define LED1_Pin GPIO_PIN_3
#define LED1_GPIO_Port GPIOE
#define LED0_Pin GPIO_PIN_4
#define LED0_GPIO_Port GPIOE
#define CH8_HV_CONV_EN_Pin GPIO_PIN_6
#define CH8_HV_CONV_EN_GPIO_Port GPIOE
#define CH8_EN_Pin GPIO_PIN_13
#define CH8_EN_GPIO_Port GPIOC
#define CH8_HV_OUT_EN_Pin GPIO_PIN_14
#define CH8_HV_OUT_EN_GPIO_Port GPIOC
#define CH7_HV_CONV_EN_Pin GPIO_PIN_15
#define CH7_HV_CONV_EN_GPIO_Port GPIOC
#define CH7_EN_Pin GPIO_PIN_9
#define CH7_EN_GPIO_Port GPIOF
#define CH7_HV_OUT_EN_Pin GPIO_PIN_10
#define CH7_HV_OUT_EN_GPIO_Port GPIOF
#define CH9_HV_CONV_EN_Pin GPIO_PIN_0
#define CH9_HV_CONV_EN_GPIO_Port GPIOC
#define CH9_EN_Pin GPIO_PIN_1
#define CH9_EN_GPIO_Port GPIOC
#define CH9_HV_OUT_EN_Pin GPIO_PIN_2
#define CH9_HV_OUT_EN_GPIO_Port GPIOC
#define CH6_HV_CONV_EN_Pin GPIO_PIN_3
#define CH6_HV_CONV_EN_GPIO_Port GPIOC
#define CH6_EN_Pin GPIO_PIN_2
#define CH6_EN_GPIO_Port GPIOF
#define EXT_INPUT1_Pin GPIO_PIN_0
#define EXT_INPUT1_GPIO_Port GPIOA
#define EXT_INPUT0_Pin GPIO_PIN_1
#define EXT_INPUT0_GPIO_Port GPIOA
#define CH6_HV_OUT_EN_Pin GPIO_PIN_6
#define CH6_HV_OUT_EN_GPIO_Port GPIOA
#define CH10_HV_CONV_EN_Pin GPIO_PIN_7
#define CH10_HV_CONV_EN_GPIO_Port GPIOA
#define CH10_EN_Pin GPIO_PIN_4
#define CH10_EN_GPIO_Port GPIOC
#define CH10_HV_OUT_EN_Pin GPIO_PIN_5
#define CH10_HV_OUT_EN_GPIO_Port GPIOC
#define CH5_HV_CONV_EN_Pin GPIO_PIN_0
#define CH5_HV_CONV_EN_GPIO_Port GPIOB
#define CH5_EN_Pin GPIO_PIN_1
#define CH5_EN_GPIO_Port GPIOB
#define CH5_HV_OUT_EN_Pin GPIO_PIN_2
#define CH5_HV_OUT_EN_GPIO_Port GPIOB
#define CH11_HV_CONV_EN_Pin GPIO_PIN_7
#define CH11_HV_CONV_EN_GPIO_Port GPIOE
#define CH11_EN_Pin GPIO_PIN_8
#define CH11_EN_GPIO_Port GPIOE
#define CH11_HV_OUT_EN_Pin GPIO_PIN_9
#define CH11_HV_OUT_EN_GPIO_Port GPIOE
#define CH4_HV_CONV_EN_Pin GPIO_PIN_10
#define CH4_HV_CONV_EN_GPIO_Port GPIOE
#define CH4_EN_Pin GPIO_PIN_11
#define CH4_EN_GPIO_Port GPIOE
#define CH4_HV_OUT_EN_Pin GPIO_PIN_12
#define CH4_HV_OUT_EN_GPIO_Port GPIOE
#define CH12_HV_CONV_EN_Pin GPIO_PIN_13
#define CH12_HV_CONV_EN_GPIO_Port GPIOE
#define CH12_EN_Pin GPIO_PIN_14
#define CH12_EN_GPIO_Port GPIOE
#define CH12_HV_OUT_EN_Pin GPIO_PIN_15
#define CH12_HV_OUT_EN_GPIO_Port GPIOE
#define CH3_HV_CONV_EN_Pin GPIO_PIN_12
#define CH3_HV_CONV_EN_GPIO_Port GPIOB
#define CH3_EN_Pin GPIO_PIN_13
#define CH3_EN_GPIO_Port GPIOB
#define CH3_HV_OUT_EN_Pin GPIO_PIN_14
#define CH3_HV_OUT_EN_GPIO_Port GPIOB
#define CH13_HV_CONV_EN_Pin GPIO_PIN_15
#define CH13_HV_CONV_EN_GPIO_Port GPIOB
#define CH13_EN_Pin GPIO_PIN_8
#define CH13_EN_GPIO_Port GPIOD
#define CH13_HV_OUT_EN_Pin GPIO_PIN_9
#define CH13_HV_OUT_EN_GPIO_Port GPIOD
#define CH2_HV_CONV_EN_Pin GPIO_PIN_10
#define CH2_HV_CONV_EN_GPIO_Port GPIOD
#define CH2_EN_Pin GPIO_PIN_11
#define CH2_EN_GPIO_Port GPIOD
#define CH2_HV_OUT_EN_Pin GPIO_PIN_12
#define CH2_HV_OUT_EN_GPIO_Port GPIOD
#define CH14_HV_CONV_EN_Pin GPIO_PIN_13
#define CH14_HV_CONV_EN_GPIO_Port GPIOD
#define CH14_EN_Pin GPIO_PIN_14
#define CH14_EN_GPIO_Port GPIOD
#define CH14_HV_OUT_EN_Pin GPIO_PIN_15
#define CH14_HV_OUT_EN_GPIO_Port GPIOD
#define CH1_HV_CONV_EN_Pin GPIO_PIN_6
#define CH1_HV_CONV_EN_GPIO_Port GPIOC
#define CH1_EN_Pin GPIO_PIN_7
#define CH1_EN_GPIO_Port GPIOC
#define CH1_HV_OUT_EN_Pin GPIO_PIN_8
#define CH1_HV_OUT_EN_GPIO_Port GPIOC
#define CH15_HV_CONV_EN_Pin GPIO_PIN_9
#define CH15_HV_CONV_EN_GPIO_Port GPIOC
#define CH15_EN_Pin GPIO_PIN_8
#define CH15_EN_GPIO_Port GPIOA
#define CH15_HV_OUT_EN_Pin GPIO_PIN_9
#define CH15_HV_OUT_EN_GPIO_Port GPIOA
#define CH0_HV_CONV_EN_Pin GPIO_PIN_10
#define CH0_HV_CONV_EN_GPIO_Port GPIOA
#define CH0_EN_Pin GPIO_PIN_11
#define CH0_EN_GPIO_Port GPIOA
#define CH0_HV_OUT_EN_Pin GPIO_PIN_12
#define CH0_HV_OUT_EN_GPIO_Port GPIOA
#define USART3_SUB_MUX0_Pin GPIO_PIN_2
#define USART3_SUB_MUX0_GPIO_Port GPIOD
#define USART3_SUB_MUX1_Pin GPIO_PIN_3
#define USART3_SUB_MUX1_GPIO_Port GPIOD
#define USART3_MUX0_Pin GPIO_PIN_4
#define USART3_MUX0_GPIO_Port GPIOD
#define USART3_MUX1_Pin GPIO_PIN_5
#define USART3_MUX1_GPIO_Port GPIOD
#define USART3_MUX2_Pin GPIO_PIN_6
#define USART3_MUX2_GPIO_Port GPIOD
/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

/**
  * @}
  */

/**
  * @}
*/

#endif /* __MAIN_H */
/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
