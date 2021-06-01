#ifndef PPG_CPP_APP_CONVERTER_H
#define PPG_CPP_APP_CONVERTER_H

#include <math.h>
#include <stdint.h>

#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <vector>

cv::Mat jpgBytesToMat(uint8_t *bytes, int32_t size);


#endif //PPG_CPP_APP_CONVERTER_H
