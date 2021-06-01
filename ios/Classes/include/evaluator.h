#ifndef PPG_CPP_APP_EVALUATOR_H
#define PPG_CPP_APP_EVALUATOR_H

#include <math.h>

#include <iostream>
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/opencv.hpp>

#define rad(angleInDegrees) ((angleInDegrees)*M_PI / 180.0)
#define deg(angleInRadians) ((angleInRadians)*180.0 / M_PI)
#define FLAG 255

int evaluatePpgValue(const cv::Mat& img, int redThreshold);


#endif //PPG_CPP_APP_EVALUATOR_H
