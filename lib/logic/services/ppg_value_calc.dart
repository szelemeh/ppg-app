import 'dart:ffi';

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';

typedef get_ppg_func = Int32 Function(Pointer<Uint8>, Int32, Int32);
typedef GetPppgValue = int Function(Pointer<Uint8>, int, int);

class PpgValueCalc {
  late GetPppgValue getPpgValue;

  PpgValueCalc() {
    final DynamicLibrary calcImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libppg_cpp.so")
        : DynamicLibrary.process();

    getPpgValue = calcImageLib
        .lookup<NativeFunction<get_ppg_func>>("getPpgValue")
        .asFunction<GetPppgValue>();
  }

  int calculate(CameraImage image) {
    Pointer<Uint8> imageBytesPointer =
        calloc.allocate(image.planes[0].bytes.length);

    Uint8List pointerList =
        imageBytesPointer.asTypedList(image.planes[0].bytes.length);

    pointerList.setRange(
        0, image.planes[0].bytes.length, image.planes[0].bytes);

    int ppgValue =
        getPpgValue(imageBytesPointer, image.planes[0].bytes.length, 225);

    print(ppgValue);
    return ppgValue;
  }
}
