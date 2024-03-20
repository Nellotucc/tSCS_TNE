#ifndef __MISC_FUNCTION_H
#define __MISC_FUNCTION_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Include */
#include <stdint.h>


/* Prototype */
void 			Delay_us_dummy(uint32_t t_uS);
void 			Delay_ms_dummy(uint32_t t_mS);
void			DummyLedBlink(void);


#ifdef __cplusplus
}
#endif

#endif 
