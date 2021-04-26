#include <fstream>
#include <iostream>
#include <vector>
#include "../include/ppg.h"
#include "evaluator.cpp"


using namespace std;
using namespace cv;


vector<uint8_t> readVectorFromDisk(const string &filePath) {
    ifstream instream(filePath, ios::in | ios::binary);
    vector<uint8_t> data((istreambuf_iterator<char>(instream)),
                         istreambuf_iterator<char>());
    return data;
}

int main(int argc, char const *argv[]) {
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
    return 0;
}