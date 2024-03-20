/**
  ******************************************************************************
  * File Name          : main.h
  * Description        : This file contains the common defines of the application
  ******************************************************************************
  *
  * COPYRIGHT(c) 2017 STMicroelectronics
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
#define SOFTWARE_VERSION							(0x01)
/* USER CODE END Includes */

/* Private define ------------------------------------------------------------*/

#define FB_PROB_Pin GPIO_PIN_0
#define FB_PROB_GPIO_Port GPIOA
#define HV_POS_PROB_Pin GPIO_PIN_2
#define HV_POS_PROB_GPIO_Port GPIOA
#define HV_NEG_PROB_Pin GPIO_PIN_7
#define HV_NEG_PROB_GPIO_Port GPIOA
#define LED0_Pin GPIO_PIN_3
#define LED0_GPIO_Port GPIOB
#define LED1_Pin GPIO_PIN_4
#define LED1_GPIO_Port GPIOB
/* USER CODE BEGIN Private defines */

//MainStatus register bits
#define RUN_CYCLIC_SUPERVISION_TASK			(0x00000001)
#define REQUEST_STATUS									(0x00000002)	//mis � 1 lorsque le uC re�ois un message lui demandantde renvoyer son �tat
#define LAST_MSG_ERR										(0x00000004)	//mis � 1 lorsque le dernier message re�us via la liaison UART �tait non valide

/* USER CODE END Private defines */

/**
  * @}
  */ 

/**
  * @}
*/ 

#endif /* __MAIN_H */
/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
