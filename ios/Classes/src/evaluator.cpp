#include "../include/evaluator.h"

using namespace std;
using namespace cv;

struct MyPoint {
    int x, y;
};

Mat createBitmask(const Mat &img, int redThreshold) {
    Mat bitmask = Mat(img.size(), CV_8UC1);
    extractChannel(img, bitmask, 2);
    for (int i = 0; i < bitmask.rows; i++)
        for (int j = 0; j < bitmask.cols; j++) {
            int redComponent = bitmask.at<uchar>(i, j);
            if (redComponent > redThreshold) {
                bitmask.at<uchar>(i, j) = FLAG;
            } else {
                bitmask.at<uchar>(i, j) = 0;
            }
        }
    return bitmask;
}

bool isFlagged(Mat bitmask, int x, int y) {
    return bitmask.at<uchar>(x, y) == FLAG;
}

MyPoint calculateCenter(const Mat &bitmask) {
    double xAvg = 0;
    double yAvg = 0;
    int count = 1;
    for (int x = 0; x < bitmask.rows; x++) {
        for (int y = 0; y < bitmask.cols; y++) {
            if (isFlagged(bitmask, x, y)) {
                xAvg = xAvg + (x - xAvg) / count;
                yAvg = yAvg + (y - yAvg) / count;
                count += 1;
            }
        }
    }
    MyPoint center{};
    center.x = (int) xAvg;
    center.y = (int) yAvg;
    return center;
}

int directionLine(double angle, int x, int centerY) {
    return (int) (tan(angle) * x + centerY);
}

bool isInsideFrame(int coord, int size) { return 0 < coord && coord < size; }

bool isInsideBitmasked(const Mat &bitmask, int x, int y) {
    int margin = 2;
    int voteYes = 0;
    int voteNo = 0;
    for (int i = x - margin; i < x + margin; i++) {
        for (int j = y - margin; j < y + margin; j++) {
            if (isInsideFrame(i, bitmask.rows) &&
                isInsideFrame(j, bitmask.cols)) {
                if (isFlagged(bitmask, i, j)) {
                    voteYes += 1;
                } else {
                    voteNo += 1;
                }
            }
        }
    }
    bool result = voteYes > voteNo;
    return result;
}

int calculateRadiusInOneDirection(const Mat &bitmask, double angle, MyPoint center,
                                  bool forwardMove) {
    int width = bitmask.rows;
    int height = bitmask.cols;
    int mx = center.x;
    int my;
    bool hitBorder = false;
    int distance = 0;
    while (isInsideFrame(mx, width)) {
        my = directionLine(angle, mx, center.y);
        if (isInsideFrame(my, height)) {
            distance += 1;
            if (!isInsideBitmasked(bitmask, mx, my)) {
                hitBorder = true;
                break;
            }
        } else {
            break;
        }
        mx = forwardMove ? mx + 1 : mx - 1;
    }
    if (hitBorder) {
        return distance;
    }
    return -1;
}

int calculateRadius(const Mat &bitmask, MyPoint center) {
    vector<int> radiuses;
    int distanceOrInvalid;
    double angles[] = {rad(0), rad(45), rad(90), rad(135)};
    for (double angle : angles) {
        distanceOrInvalid =
                calculateRadiusInOneDirection(bitmask, angle, center, true);
        if (distanceOrInvalid != -1) {
            radiuses.push_back(distanceOrInvalid);
        }
        distanceOrInvalid =
                calculateRadiusInOneDirection(bitmask, angle, center, false);
        if (distanceOrInvalid != -1) {
            radiuses.push_back(distanceOrInvalid);
        }
    }
    int sum = 0;
    int size = (int) radiuses.size();
    for (int i = 0; i < size; i++) {
        sum += radiuses[i];
    }
    return sum / size;
}

int evaluatePpgValue(const Mat& img, int redThreshold) {
    Mat bitmask = createBitmask(img, redThreshold);
    MyPoint center = calculateCenter(bitmask);
    int radius = calculateRadius(bitmask, center);
    return radius;
}