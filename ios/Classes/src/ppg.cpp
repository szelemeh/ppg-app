#include "../include/ppg.h"
#include "./verifier.cpp"

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t getPpgValue(uint8_t *bytes, int32_t size, int32_t redThreshold) {
    cv::Mat img = jpgBytesToMat(bytes, size);
    if (verify(img)) {
        int value = evaluatePpgValue(img, redThreshold);
        return value;
    }
    return -1;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t *calibrateFrame(uint8_t *bytes, int32_t size) {
    cv::Mat img = jpgBytesToMat(bytes, size);
    auto *output = (int32_t *) malloc(sizeof(int32_t) * 2);
    if (verify(img)) {
        FrameStats results = getFrameStatistics(img);
        output[0] = results.redMax;
        output[1] = results.redMin;
        return output;
    }
    output[0] = -1;
    output[1] = -1;
    return output;
}

