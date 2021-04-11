import 'dart:ffi';

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';

typedef calc_function = Uint32 Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32, Int32);
typedef Calculate = int Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int, int);

class PpgValueCalc {
  late Calculate calc;

  PpgValueCalc() {
    final DynamicLibrary calcImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libppg_calc.so")
        : DynamicLibrary.process();

    calc = calcImageLib
        .lookup<NativeFunction<calc_function>>("calculate_ppg_value_from_image")
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

    int result = calc(p0, p1, p2, image.planes[1].bytesPerRow,
        image.planes[1].bytesPerPixel!, image.width, image.height, 50);


    calloc.free(p0);
    calloc.free(p1);
    calloc.free(p2);

    return result;
  }
}
