#include "../include/ppg.h"


extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t getPpgValue(uint8_t *bytes, int32_t size, int32_t redThreshold) {
    cv::Mat img = jpgBytesToMat(bytes, size);
    int value = evaluatePpgValue(img, redThreshold);
    return value;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t *calibrateFrame(uint8_t *bytes, int32_t size) {
    cv::Mat img = jpgBytesToMat(bytes, size);
    FrameStats results = getFrameStatistics(img);
    auto *output = (int32_t *) malloc(sizeof(int32_t) * 2);
    output[0] = results.redMax;
    output[1] = results.redMin;
    return output;
}

