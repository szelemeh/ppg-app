#include "../include/ppg.h"


extern "C" __attribute__((visibility("default"))) __attribute__((used)) int32_t
getPpgValue(uint8_t *bytes, int32_t size, int32_t redThreshold) {
    cv::Mat img = jpgBytesToMat(bytes, size);
    int value = evaluatePpgValue(img, redThreshold);
    return value;
}
