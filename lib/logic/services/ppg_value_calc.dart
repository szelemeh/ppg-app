import 'dart:ffi';

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:ppg_hrv_app/logic/models/frame_stats.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';

typedef get_ppg_func = Int32 Function(Pointer<Uint8>, Int32, Int32);
typedef GetPppgValue = int Function(Pointer<Uint8>, int, int);

typedef calibrate_frame_func = Pointer<Int32> Function(Pointer<Uint8>, Int32);
typedef CalibrateFrame = Pointer<Int32> Function(Pointer<Uint8>, int);

class PpgValueCalc {
  late GetPppgValue _getPpgValue;
  late CalibrateFrame _calibrateFrame;

  PpgValueCalc() {
    final DynamicLibrary calcImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libppg_cpp.so")
        : DynamicLibrary.process();

    _getPpgValue = calcImageLib
        .lookup<NativeFunction<get_ppg_func>>("getPpgValue")
        .asFunction<GetPppgValue>();

    _calibrateFrame = calcImageLib
        .lookup<NativeFunction<calibrate_frame_func>>("calibrateFrame")
        .asFunction<CalibrateFrame>();
  }

  PpgPoint evaluate(CameraImage img) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    Pointer<Uint8> imageBytesPointer = this._getImageBytesPointer(img);

    int ppgValue =
        _getPpgValue(imageBytesPointer, img.planes[0].bytes.length, 225);

    print(ppgValue);
    return PpgPoint(
      timestamp: timestamp,
      value: ppgValue,
    );
  }

  FrameStats getFrameStats(CameraImage img) {
    Pointer<Uint8> imageBytesPointer = this._getImageBytesPointer(img);
    Pointer<Int32> result =
        _calibrateFrame(imageBytesPointer, img.planes[0].bytes.length);
    List<int> statsList = result.asTypedList(2).toList();
    FrameStats stats = FrameStats(redMax: statsList[0], redMin: statsList[1]);
    return stats;
  }

  Pointer<Uint8> _getImageBytesPointer(CameraImage img) {
    Pointer<Uint8> imageBytesPointer =
        calloc.allocate(img.planes[0].bytes.length);

    Uint8List pointerList =
        imageBytesPointer.asTypedList(img.planes[0].bytes.length);

    pointerList.setRange(0, img.planes[0].bytes.length, img.planes[0].bytes);

    return imageBytesPointer;
  }
}
