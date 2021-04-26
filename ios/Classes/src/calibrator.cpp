#include "../include/calibrator.h"

using namespace cv;
using namespace std;

FrameStats getFrameStatistics(Mat &frame) {
    FrameStats results{};
    results.redMax = -1;
    results.redMin = 255;

    // accept only colored frames
    CV_Assert(frame.channels() == 3);
    // accept only char type matrices
    CV_Assert(frame.depth() == CV_8U);

    MatIterator_<Vec3b> it, end;
    for (it = frame.begin<Vec3b>(), end = frame.end<Vec3b>(); it != end; ++it) {
        int red = (int) (*it)[2];
        if (red > results.redMax) {
            results.redMax = red;
        }
        if (red < results.redMin) {
            results.redMin = red;
        }
    }
    return results;
}
