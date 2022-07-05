#ifndef PPG_CPP_APP_CALIBRATOR_H
#define PPG_CPP_APP_CALIBRATOR_H

struct FrameStats {
    int redMax;
    int redMin;
};

#include <opencv2/opencv.hpp>

FrameStats getFrameStatistics(cv::Mat &frame);

#endif //PPG_CPP_APP_CALIBRATOR_H
