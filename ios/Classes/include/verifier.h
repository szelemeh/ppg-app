#ifndef PPG_CPP_APP_VERIFIER_H
#define PPG_CPP_APP_VERIFIER_H

#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <vector>
#include <iostream>
#include <numeric>

struct ChannelVerification {
    double delta;
    double mean = 128;
    double variance = 0;
};

bool verify(cv::Mat &img);

#endif //PPG_CPP_APP_VERIFIER_H
