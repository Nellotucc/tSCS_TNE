/**
  ******************************************************************************
  * File Name          : main.c
  * Description        : Main program body
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
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "stm32f3xx_hal.h"

/* USER CODE BEGIN Includes */
#include "CHANNEL_COM_function.h"
#include "MASTER_COM_function.h"
#include "MISC_function.h"

/* USER CODE END Includes */

/* Private variables ---------------------------------------------------------*/
TIM_HandleTypeDef htim6;

UART_HandleTypeDef huart2;
UART_HandleTypeDef huart3;
DMA_HandleTypeDef hdma_usart2_rx;
DMA_HandleTypeDef hdma_usart2_tx;
DMA_HandleTypeDef hdma_usart3_rx;
DMA_HandleTypeDef hdma_usart3_tx;

/* USER CODE BEGIN PV */
/* Private variables ---------------------------------------------------------*/
volatile uint32_t		MainStatus	= 0x00000000;

volatile float 			DebugVar0 	= 0.0;
volatile float 			DebugVar1 	= 0.0;
volatile uint32_t		DebugVar2 	= 0;
volatile uint8_t 		DebugVar4 	= 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
void Error_Handler(void);
static void MX_GPIO_Init(void);
static void MX_DMA_Init(void);
static void MX_TIM6_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_USART3_UART_Init(void);

/* USER CODE BEGIN PFP */
/* Private function prototypes -----------------------------------------------*/
void MiscInit(void);
/* USER CODE END PFP */

/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration----------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* Configure the system clock */
  SystemClock_Config();

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_TIM6_Init();
  MX_USART2_UART_Init();
  MX_USART3_UART_Init();

  /* USER CODE BEGIN 2 */
	MiscInit();
	CHANNEL_Initial_Test_All();
	//CHANNEL_cmd(1, ENABLE, DISABLE, DISABLE);
	
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
  /* USER CODE END WHILE */

  /* USER CODE BEGIN 3 */
//		Delay_ms_dummy(500);
//		LED0_GPIO_Port->ODR	^= LED0_Pin;		
		CHANNEL_UART_rx_handler();
		MASTER_UART_rx_handler();
//		if(PUSH_BUTTON_INPUT_GPIO_Port->IDR & PUSH_BUTTON_INPUT_Pin){
//			CHANNEL_cmd(0, ENABLE, DISABLE, DISABLE);
//			LED0_GPIO_Port->ODR	|= LED0_Pin;	
//		}else{
//			CHANNEL_cmd(0, ENABLE, ENABLE, DISABLE);
//			LED0_GPIO_Port->ODR	&=~LED0_Pin;	
////			CHANNEL_get_status(0);
////			if(DebugVar4){
////				CHANNEL_cmd(0, DISABLE, DISABLE, DISABLE);
////				LED0_GPIO_Port->ODR	&=~LED0_Pin;	
////				DebugVar4=0;
////			}else{
////				LED0_GPIO_Port->ODR	|= LED0_Pin;	
////				CHANNEL_cmd(0, ENABLE, DISABLE, DISABLE);

////				DebugVar4=1;
////			}
//			Delay_ms_dummy(300);
////			CHANNEL_Set_All_Param(0, 200, 50, 1000, 10000, 2, 20);
//		}
//		CHANNEL_get_status(0);
  }
  /* USER CODE END 3 */

}

/** System Clock Configuration
*/
void SystemClock_Config(void)
{

  RCC_OscInitTypeDef RCC_OscInitStruct;
  RCC_ClkInitTypeDef RCC_ClkInitStruct;
  RCC_PeriphCLKInitTypeDef PeriphClkInit;

    /**Initializes the CPU, AHB and APB busses clocks
    */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = 16;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL16;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

    /**Initializes the CPU, AHB and APB busses clocks
    */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }

  PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_USART2|RCC_PERIPHCLK_USART3;
  PeriphClkInit.Usart2ClockSelection = RCC_USART2CLKSOURCE_PCLK1;
  PeriphClkInit.Usart3ClockSelection = RCC_USART3CLKSOURCE_PCLK1;
  if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK)
  {
    Error_Handler();
  }

    /**Configure the Systick interrupt time
    */
  HAL_SYSTICK_Config(HAL_RCC_GetHCLKFreq()/1000);

    /**Configure the Systick
    */
  HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);

  /* SysTick_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(SysTick_IRQn, 0, 0);
}

/* TIM6 init function */
static void MX_TIM6_Init(void)
{

  TIM_MasterConfigTypeDef sMasterConfig;

  htim6.Instance = TIM6;
  htim6.Init.Prescaler = 72;
  htim6.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim6.Init.Period = 9999;
  if (HAL_TIM_Base_Init(&htim6) != HAL_OK)
  {
    Error_Handler();
  }

  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim6, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }

}

/* USART2 init function */
static void MX_USART2_UART_Init(void)
{

  huart2.Instance = USART2;
  huart2.Init.BaudRate = 921600;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  huart2.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  huart2.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  if (HAL_UART_Init(&huart2) != HAL_OK)
  {
    Error_Handler();
  }

}

/* USART3 init function */
static void MX_USART3_UART_Init(void)
{

  huart3.Instance = USART3;
  huart3.Init.BaudRate = 1000000;
  huart3.Init.WordLength = UART_WORDLENGTH_8B;
  huart3.Init.StopBits = UART_STOPBITS_1;
  huart3.Init.Parity = UART_PARITY_NONE;
  huart3.Init.Mode = UART_MODE_TX_RX;
  huart3.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart3.Init.OverSampling = UART_OVERSAMPLING_16;
  huart3.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
  huart3.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
  if (HAL_UART_Init(&huart3) != HAL_OK)
  {
    Error_Handler();
  }

}

/**
  * Enable DMA controller clock
  */
static void MX_DMA_Init(void)
{
  /* DMA controller clock enable */
  __HAL_RCC_DMA1_CLK_ENABLE();

  /* DMA interrupt init */
  /* DMA1_Channel2_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel2_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel2_IRQn);
  /* DMA1_Channel3_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel3_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel3_IRQn);
  /* DMA1_Channel6_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel6_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel6_IRQn);
  /* DMA1_Channel7_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(DMA1_Channel7_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(DMA1_Channel7_IRQn);

}

/** Configure pins as
        * Analog
        * Input
        * Output
        * EVENT_OUT
        * EXTI
*/
static void MX_GPIO_Init(void)
{

  GPIO_InitTypeDef GPIO_InitStruct;

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOE_CLK_ENABLE();
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOF_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOE, LED1_Pin|LED0_Pin|CH8_HV_CONV_EN_Pin|CH11_HV_CONV_EN_Pin
                          |CH11_EN_Pin|CH11_HV_OUT_EN_Pin|CH4_HV_CONV_EN_Pin|CH4_EN_Pin
                          |CH4_HV_OUT_EN_Pin|CH12_HV_CONV_EN_Pin|CH12_EN_Pin|CH12_HV_OUT_EN_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOC, CH8_EN_Pin|CH8_HV_OUT_EN_Pin|CH7_HV_CONV_EN_Pin|CH9_HV_CONV_EN_Pin
                          |CH9_EN_Pin|CH9_HV_OUT_EN_Pin|CH6_HV_CONV_EN_Pin|CH10_EN_Pin
                          |CH10_HV_OUT_EN_Pin|CH1_HV_CONV_EN_Pin|CH1_EN_Pin|CH1_HV_OUT_EN_Pin
                          |CH15_HV_CONV_EN_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOF, CH7_EN_Pin|CH7_HV_OUT_EN_Pin|CH6_EN_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, CH6_HV_OUT_EN_Pin|CH10_HV_CONV_EN_Pin|CH15_EN_Pin|CH15_HV_OUT_EN_Pin
                          |CH0_HV_CONV_EN_Pin|CH0_EN_Pin|CH0_HV_OUT_EN_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, CH5_HV_CONV_EN_Pin|CH5_EN_Pin|CH5_HV_OUT_EN_Pin|CH3_HV_CONV_EN_Pin
                          |CH3_EN_Pin|CH3_HV_OUT_EN_Pin|CH13_HV_CONV_EN_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOD, CH13_EN_Pin|CH13_HV_OUT_EN_Pin|CH2_HV_CONV_EN_Pin|CH2_EN_Pin
                          |CH2_HV_OUT_EN_Pin|CH14_HV_CONV_EN_Pin|CH14_EN_Pin|CH14_HV_OUT_EN_Pin
                          |USART3_SUB_MUX0_Pin|USART3_SUB_MUX1_Pin|USART3_MUX0_Pin|USART3_MUX1_Pin
                          |USART3_MUX2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : PUSH_BUTTON_INPUT0_Pin */
  GPIO_InitStruct.Pin = PUSH_BUTTON_INPUT0_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(PUSH_BUTTON_INPUT0_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : LED1_Pin LED0_Pin */
  GPIO_InitStruct.Pin = LED1_Pin|LED0_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pins : CH8_HV_CONV_EN_Pin CH11_HV_CONV_EN_Pin CH11_EN_Pin CH11_HV_OUT_EN_Pin
                           CH4_HV_CONV_EN_Pin CH4_EN_Pin CH4_HV_OUT_EN_Pin CH12_HV_CONV_EN_Pin
                           CH12_EN_Pin CH12_HV_OUT_EN_Pin */
  GPIO_InitStruct.Pin = CH8_HV_CONV_EN_Pin|CH11_HV_CONV_EN_Pin|CH11_EN_Pin|CH11_HV_OUT_EN_Pin
                          |CH4_HV_CONV_EN_Pin|CH4_EN_Pin|CH4_HV_OUT_EN_Pin|CH12_HV_CONV_EN_Pin
                          |CH12_EN_Pin|CH12_HV_OUT_EN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);

  /*Configure GPIO pins : CH8_EN_Pin CH8_HV_OUT_EN_Pin CH7_HV_CONV_EN_Pin CH9_HV_CONV_EN_Pin
                           CH9_EN_Pin CH9_HV_OUT_EN_Pin CH6_HV_CONV_EN_Pin CH10_EN_Pin
                           CH10_HV_OUT_EN_Pin CH1_HV_CONV_EN_Pin CH1_EN_Pin CH1_HV_OUT_EN_Pin
                           CH15_HV_CONV_EN_Pin */
  GPIO_InitStruct.Pin = CH8_EN_Pin|CH8_HV_OUT_EN_Pin|CH7_HV_CONV_EN_Pin|CH9_HV_CONV_EN_Pin
                          |CH9_EN_Pin|CH9_HV_OUT_EN_Pin|CH6_HV_CONV_EN_Pin|CH10_EN_Pin
                          |CH10_HV_OUT_EN_Pin|CH1_HV_CONV_EN_Pin|CH1_EN_Pin|CH1_HV_OUT_EN_Pin
                          |CH15_HV_CONV_EN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pins : CH7_EN_Pin CH7_HV_OUT_EN_Pin CH6_EN_Pin */
  GPIO_InitStruct.Pin = CH7_EN_Pin|CH7_HV_OUT_EN_Pin|CH6_EN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOF, &GPIO_InitStruct);

  /*Configure GPIO pins : EXT_INPUT1_Pin EXT_INPUT0_Pin */
  GPIO_InitStruct.Pin = EXT_INPUT1_Pin|EXT_INPUT0_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : CH6_HV_OUT_EN_Pin CH10_HV_CONV_EN_Pin CH15_EN_Pin CH15_HV_OUT_EN_Pin
                           CH0_HV_CONV_EN_Pin CH0_EN_Pin CH0_HV_OUT_EN_Pin */
  GPIO_InitStruct.Pin = CH6_HV_OUT_EN_Pin|CH10_HV_CONV_EN_Pin|CH15_EN_Pin|CH15_HV_OUT_EN_Pin
                          |CH0_HV_CONV_EN_Pin|CH0_EN_Pin|CH0_HV_OUT_EN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pins : CH5_HV_CONV_EN_Pin CH5_EN_Pin CH5_HV_OUT_EN_Pin CH3_HV_CONV_EN_Pin
                           CH3_EN_Pin CH3_HV_OUT_EN_Pin CH13_HV_CONV_EN_Pin */
  GPIO_InitStruct.Pin = CH5_HV_CONV_EN_Pin|CH5_EN_Pin|CH5_HV_OUT_EN_Pin|CH3_HV_CONV_EN_Pin
                          |CH3_EN_Pin|CH3_HV_OUT_EN_Pin|CH13_HV_CONV_EN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /*Configure GPIO pins : CH13_EN_Pin CH13_HV_OUT_EN_Pin CH2_HV_CONV_EN_Pin CH2_EN_Pin
                           CH2_HV_OUT_EN_Pin CH14_HV_CONV_EN_Pin CH14_EN_Pin CH14_HV_OUT_EN_Pin */
  GPIO_InitStruct.Pin = CH13_EN_Pin|CH13_HV_OUT_EN_Pin|CH2_HV_CONV_EN_Pin|CH2_EN_Pin
                          |CH2_HV_OUT_EN_Pin|CH14_HV_CONV_EN_Pin|CH14_EN_Pin|CH14_HV_OUT_EN_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

  /*Configure GPIO pins : USART3_SUB_MUX0_Pin USART3_SUB_MUX1_Pin USART3_MUX0_Pin USART3_MUX1_Pin
                           USART3_MUX2_Pin */
  GPIO_InitStruct.Pin = USART3_SUB_MUX0_Pin|USART3_SUB_MUX1_Pin|USART3_MUX0_Pin|USART3_MUX1_Pin
                          |USART3_MUX2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOD, &GPIO_InitStruct);

}

/* USER CODE BEGIN 4 */




/**
  * @brief  Divers choses à effectuer après un rst (pas mis dans le main pour éviter les conflic avec stmcubemx) 
  * @param  None
  * @retval None
  */
void MiscInit(void){
//	TeCycle_us = (uint32_t)(htim6.Init.Period+1);
//	HAL_TIM_Base_Start_IT(&htim6);								// Activation des interuption de la boucle principale
	#ifdef PROTO_BOARD
		GPIO_InitTypeDef GPIO_InitStruct;
		GPIO_InitStruct.Pin 	= PUSH_BUTTON_INPUT_Pin;
		GPIO_InitStruct.Mode 	= GPIO_MODE_INPUT;
		GPIO_InitStruct.Pull 	= GPIO_NOPULL;
		HAL_GPIO_Init(PUSH_BUTTON_INPUT_GPIO_Port, &GPIO_InitStruct);
	#endif
	CHANNEL_UART_rx_init();
	MASTER_UART_rx_init();
}
//END MiscInit




/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @param  None
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler */
  /* User can add his own implementation to report the HAL error return state */
  while(1) 
  {
  }
  /* USER CODE END Error_Handler */
}

#ifdef USE_FULL_ASSERT

/**
   * @brief Reports the name of the source file and the source line number
   * where the assert_param error has occurred.
   * @param file: pointer to the source file name
   * @param line: assert_param error line source number
   * @retval None
   */
void assert_failed(uint8_t* file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
    ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */

}

#endif

/**
  * @}
  */

/**
  * @}
*/

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
