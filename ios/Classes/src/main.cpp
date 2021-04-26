#include <fstream>
#include <iostream>
#include <vector>
#include "../include/ppg.h"
#include "evaluator.cpp"
#include "calibrator.cpp"


using namespace std;
using namespace cv;


vector<uint8_t> readVectorFromDisk(const string &filePath) {
    ifstream instream(filePath, ios::in | ios::binary);
    vector<uint8_t> data((istreambuf_iterator<char>(instream)),
                         istreambuf_iterator<char>());
    return data;
}

void video_test() {
    string filename = "/Users/subzarro/Desktop/ZSC/etap2/test_video.mp4";
    VideoCapture capture(filename);
    Mat frame;

    if( !capture.isOpened() )
        throw "Error when reading steam_avi";

    namedWindow( "w", 1);
    for( ; ; )
    {
        capture >> frame;
        if(frame.empty())
            break;
        Mat bitmask = createBitmask(frame, 220);
        MyPoint center = calculateCenter(bitmask);
        int radius = calculateRadius(bitmask, center);
        cout << radius << endl;
        imshow("w", bitmask);
        waitKey(16); // waits to display frame
    }
    waitKey(0); // key press to close window
    // releases and window destroy are automatic in C++ interface
}

void calibrationTest() {
    Mat frame = imread("/Users/subzarro/SchoolProjects/ppg_hrv_app/ios/Classes/assets/scan.jpg");
    FrameStats r = calibrateFrame(frame);
    cout << r.redMax << endl;
    cout << r.redMin << endl;
}

int main(int argc, char const *argv[]) {
    calibrationTest();
    return 0;
}