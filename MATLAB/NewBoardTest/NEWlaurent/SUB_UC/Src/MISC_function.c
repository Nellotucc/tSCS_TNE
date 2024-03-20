#include "MISC_function.h"
#include "stm32f1xx_hal.h"
#include "main.h"	 



/**
  * @brief  Dummy delay function 
  * @param  t_ms: Delay time in [ms] (approximative value based on a 24MHz core clock on stm32f? (level 3 code optimisation))
  * @retval None
  */
void Delay_ms_dummy(uint32_t t_mS){
	if(t_mS>100000)	//max 100s
		t_mS=100000;
	t_mS*=2000;
	while(t_mS--){
		__asm{NOP};
		__asm{NOP};
		__asm{NOP};
		__asm{NOP};
		__asm{NOP};
	}
}
//END Delay_ms_dummy



/**
  * @brief  Dummy delay function 
  * @param  t_us: Delay time in [ms] (approximative value based on a 72MHz core clock on stm32f303 (level 3 code optimisation))
  * @retval None
  */
void Delay_us_dummy(uint32_t t_uS){
	t_uS*=2;
	while(t_uS--){
		__asm{NOP};
		__asm{NOP};
		__asm{NOP};
		__asm{NOP};
		__asm{NOP};
	}
}
//END Delay_ms_dummy



/**
  * @brief  Dummy delay function 
  * @param  t_ms: Delay time in [ms] (approximative value based on a 72MHz core clock on stm32f303 (level 3 code optimisation))
  * @retval None
  */
void DummyLedBlink(void){
	LED0_GPIO_Port->ODR |= LED0_Pin;
	Delay_ms_dummy(5);
	LED0_GPIO_Port->ODR &=~LED0_Pin;
	Delay_ms_dummy(500);
}
//END DummyLedBlink
