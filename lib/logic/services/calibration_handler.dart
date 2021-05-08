import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/frame_stats.dart';

import 'native_method_caller.dart';


class CalibrationHandler {
  late Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();

  final _input = StreamController<CameraImage>();
  final _output = StreamController<FrameStats>();

  Stream<FrameStats> get outputStream => _output.stream;

  Future<dynamic> initialize() async {
    try {
      _isolate = await _createIsolate();

      _receivePort.listen((message) {
        if (message is SendPort) {
          _handleReceivedSendPort(message);
        } else if (message is FrameStats) {
          _handleReceivedFrameStats(message);
        } else {
          _handleReceivedAny(message);
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  _handleReceivedSendPort(SendPort sendPort) {
    _input.stream.listen((img) {
      sendPort.send(img);
    });
  }

  void _handleReceivedFrameStats(FrameStats frameStats) {
    _output.add(frameStats);
  }

  void _handleReceivedAny(dynamic msg) {
    log("CalibrationHandler: unknown message: $msg");
  }

  static void _evaluate(SendPort sendPort) {
    log("CalibrationHandler: isolate started.");
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    final NativeMethodCaller methodCaller = NativeMethodCaller();
    receivePort.listen((msg) {
      if (msg is CameraImage) {
        FrameStats stats = methodCaller.getFrameStats(msg);
        sendPort.send(stats);
      }
    });
  }

  void handleImage(CameraImage img) {
    _input.add(img);
  }

  _createIsolate() async {
    return Isolate.spawn(_evaluate, _receivePort.sendPort);
  }

  dispose() {
    _isolate.kill();
    _receivePort.close();
  }
}
