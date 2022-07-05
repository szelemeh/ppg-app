#include "../include/verifier.h"

using namespace std;
using namespace cv;

const int G_MIN = 3;
const int G_MAX = 128;
const int R_MIN = 128;
const int B_MAX = 128;
const int STD = 40;

void performStep(int i, int val, ChannelVerification &channel) {
    channel.delta = val - channel.mean;
    channel.mean += (double) channel.delta / (i + 1);
    channel.variance += (double) channel.delta * (val - channel.mean);
}

bool verifyBlueChannel(double stdDev, double mean) {
    return mean + stdDev < B_MAX;
}

bool verifyGreenChannel(double stdDev, double mean) {
    return mean + stdDev > G_MIN &&
           mean + stdDev < G_MAX;
}

bool verifyRedChannel(double stdDev, double mean) {
    return mean - stdDev >= R_MIN;
}

bool verifyAllChannels(ChannelVerification &blue, ChannelVerification &green, ChannelVerification &red) {
    double blueStdDev = sqrt(green.variance);
    double greenStdDev = sqrt(green.variance);
    double redStdDev = sqrt(green.variance);
    return verifyBlueChannel(blueStdDev, blue.mean) &&
           verifyGreenChannel(greenStdDev, green.mean) &&
           verifyRedChannel(redStdDev, red.mean) &&
           blueStdDev < STD &&
           greenStdDev < STD &&
           redStdDev < STD;
}

bool verify(Mat &img) {
    ChannelVerification blue;
    ChannelVerification green;
    ChannelVerification red;

    MatIterator_<Vec3b> it = img.begin<Vec3b>(), end = img.end<Vec3b>();
    int i = 1;
    blue.mean = (double) (*it)[0];
    green.mean = (double) (*it)[1];
    red.mean = (double) (*it)[2];
    for (it = it + 1; it != end; ++it, i++) {
        int blueVal = (int) (*it)[0];
        performStep(i, blueVal, blue);
        int greenVal = (int) (*it)[1];
        performStep(i, greenVal, green);
        int redVal = (int) (*it)[2];
        performStep(i, redVal, red);
    }
    blue.variance = blue.variance / (i - 1);
    green.variance = green.variance / (i - 1);
    red.variance = red.variance / (i - 1);
    return verifyAllChannels(blue, green, red);
}
