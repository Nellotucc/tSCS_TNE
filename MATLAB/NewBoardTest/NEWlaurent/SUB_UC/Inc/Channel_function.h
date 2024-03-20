#ifndef __DAC_FUNCTION_H
#define __DAC_FUNCTION_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Include */
#include <stdint.h>


/* Prototype */
void Channel_UpdateOutput(void);
void Channel_SetPulseWidth(uint32_t PulseWidth_us);
void Channel_SetDeadTimeWidth(uint32_t DeadTimeWidth_us);
void Channel_SetInterPulseTimeWidth(uint32_t InterPulseTimeWidth_us);
void Channel_SetInterFrameTimeWidth(uint32_t InterFrameTimeWidth_us);
void Channel_SetPulseRepetitionCnt(uint32_t PulseRepetitionCnt);
void Channel_SetAmplitude(float Amplitude_mA);
void Channel_SetMode(uint32_t Mode);
void Channel_ManualPulseTrigger(void);
	 
#ifdef __cplusplus
}
#endif

#endif 
