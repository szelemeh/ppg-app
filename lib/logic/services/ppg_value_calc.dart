import 'dart:ffi';

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';

typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

class PpgValueCalc {
  late Convert calc;

  PpgValueCalc() {
    final DynamicLibrary calcImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvertImage.so")
        : DynamicLibrary.process();

    calc = calcImageLib
        .lookup<NativeFunction<convert_func>>("convertImage")
        .asFunction<Convert>();
  }

  int calculate(CameraImage image) {
    Pointer<Uint8> p0 = calloc.allocate(image.planes[0].bytes.length);
    Pointer<Uint8> p1 = calloc.allocate(image.planes[0].bytes.length);
    Pointer<Uint8> p2 = calloc.allocate(image.planes[0].bytes.length);

    Uint8List pointerList = p0.asTypedList(image.planes[0].bytes.length);
    Uint8List pointerList1 = p1.asTypedList(image.planes[1].bytes.length);
    Uint8List pointerList2 = p2.asTypedList(image.planes[2].bytes.length);

    pointerList.setRange(
        0, image.planes[0].bytes.length, image.planes[0].bytes);
    pointerList1.setRange(
        0, image.planes[1].bytes.length, image.planes[1].bytes);
    pointerList2.setRange(
        0, image.planes[2].bytes.length, image.planes[2].bytes);

    Pointer<Uint32> imgP = calc(p0, p1, p2, image.planes[1].bytesPerRow,
        image.planes[1].bytesPerPixel!, image.width, image.height);

    Uint32List imgData = imgP.asTypedList(image.width * image.height);

    // int result = calculatePpgValue(imgData, image.width, image.height, 249);
    int result = calculatePpgValue(imgData, image.width, image.height, 50);

    calloc.free(p0);
    calloc.free(p1);
    calloc.free(p2);

    return result;
  }

  int calculatePpgValue(
      Uint32List imgData, int width, int height, int redThreshold) {
    // Create bitmask
    List<List<bool>> bitmask = [];
    for (int x = 0; x < width; x += 1) {
      List<bool> row = [];
      for (int y = 0; y < height; y += 1) {
        int index = y + x * width;
        if (index < imgData.length) {
          int pixel = imgData[index];
          List<int> bytes = List.generate(4, (n) => (pixel >> (8 * n)) & 0xFF);
          int red = bytes[0];
          row.add(red > redThreshold);
        }
      }
      bitmask.add(row);
    }
    List<int> bitmaskBytes = imgData.map((pixel) {
      List<int> bytes = List.generate(4, (n) => (pixel >> (8 * n)) & 0xFF);
      int red = bytes[0];
      if (red > redThreshold) {
        return pixel;
      } else {
        return 0;
      }
    }).toList();

    final img = Image.fromBytes(width, height, bitmaskBytes);

    // Calculate center
    double avgX = 0;
    double avgY = 0;
    int count = 1;
    for (int x = 0; x < width; x += 1) {
      for (int y = 0; y < height; y += 1) {
        int index = y + x * width;
        if (index < bitmask.length && bitmask[x][y]) {
          avgX = (avgX + (x - avgX) / count);
          avgY = (avgY + (y - avgY) / count);
        }
        count += 1;
      }
    }
    int centerX = avgX.toInt();
    int centerY = avgY.toInt();
    print("Center: x:$centerX, y:$centerY");

    // Calculate radius
    int leftX = centerX;
    int rightX = centerX;
    int upY = centerY;
    int downY = centerY;
    int leftDistance = 0;
    int rightDistance = 0;
    int upDistance = 0;
    int downDistance = 0;
    bool leftFinished = false;
    bool rightFinished = false;
    bool upFinished = false;
    bool downFinished = false;
    bool leftFoundBorder = false;
    bool rightFoundBorder = false;
    bool upFoundBorder = false;
    bool downFoundBorder = false;
    while (true) {
      if (!leftFinished &&
          bitmask[leftX].isNotEmpty &&
          bitmask[leftX][centerY]) {
        leftX--;
        leftDistance += 1;
        if (leftX <= 0) leftFinished = true;
      } else {
        leftFinished = true;
        leftFoundBorder = true;
      }
      if (!rightFinished &&
          bitmask[rightX].isNotEmpty &&
          bitmask[rightX][centerY]) {
        rightX++;
        rightDistance += 1;
        if (rightX >= width) rightFinished = true;
      } else {
        rightFinished = true;
        rightFoundBorder = true;
      }
      if (!downFinished && bitmask[centerX][downY]) {
        downY--;
        downDistance += 1;
        if (downY <= 0) downFinished = true;
      } else {
        downFinished = true;
        downFoundBorder = true;
      }
      if (!upFinished && bitmask[upY][centerX]) {
        upY++;
        upDistance += 1;
        if (upY >= height) upFinished = true;
      } else {
        upFinished = true;
        upFoundBorder = true;
      }

      if (leftFinished && rightFinished && upFinished && downFinished) {
        break;
      }
    }
    int radiusSum = 0;
    int radiusCount = 0;
    if (leftFoundBorder) {
      radiusSum += leftDistance;
      radiusCount += 1;
    }
    if (rightFoundBorder) {
      radiusSum += rightDistance;
      radiusCount += 1;
    }
    if (upFoundBorder) {
      radiusSum += upDistance;
      radiusCount += 1;
    }
    if (downFoundBorder) {
      radiusSum += downDistance;
      radiusCount += 1;
    }
    int radius = radiusSum ~/ radiusCount;
    print("Radius: $radius");
    return radius;
  }
}
