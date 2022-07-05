#include "../include/converter.h"

using namespace std;
using namespace cv;

Mat jpgBytesToMat(uint8_t* bytes, int32_t size) {
    vector<uint8_t> data(bytes, bytes + size);
    Mat image = imdecode(data, IMREAD_UNCHANGED);
    return image;
}