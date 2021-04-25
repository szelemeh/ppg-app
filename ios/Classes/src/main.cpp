#include <fstream>
#include <iostream>
#include <vector>
#include "../include/ppg.h"


using namespace std;
using namespace cv;

vector<uint8_t> readVectorFromDisk(const string &filePath) {
    ifstream instream(filePath, ios::in | ios::binary);
    vector<uint8_t> data((istreambuf_iterator<char>(instream)),
                         istreambuf_iterator<char>());
    return data;
}

int main(int argc, char const *argv[]) {
    vector<uint8_t> bytes = readVectorFromDisk(
            "/Users/subzarro/Desktop/scan.jpg");
    int val = getPpgValue(bytes.data(), (int)bytes.size(), 220);
    cout << val << endl;
    return 0;
}