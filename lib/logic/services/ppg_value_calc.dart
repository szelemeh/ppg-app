import 'dart:ffi';

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';

typedef calc_function = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Calculate = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

class PpgValueCalc {
  late Calculate calc;

  PpgValueCalc() {
    final DynamicLibrary calcImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvert_image.so")
        : DynamicLibrary.process();

    calc = calcImageLib
        .lookup<NativeFunction<calc_function>>("convertImage")
        .asFunction<Calculate>();
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

    Pointer<Uint32> imagePointer = calc(p0, p1, p2, image.planes[1].bytesPerRow,
        image.planes[1].bytesPerPixel!, image.width, image.height);

    Uint32List list = imagePointer.asTypedList(image.width * image.height);

    print(list[0]);
    int result = imagePointer.address;

    calloc.free(p0);
    calloc.free(p1);
    calloc.free(p2);
    calloc.free(imagePointer);

    return result;
  }
}
