#ifndef PPG_CPP_APP_PPG_H
#define PPG_CPP_APP_PPG_H

#include "../include/converter.h"
#include "../include/evaluator.h"

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t getPpgValue(uint8_t *bytes, int32_t size, int32_t redThreshold);

#endif //PPG_CPP_APP_PPG_H
