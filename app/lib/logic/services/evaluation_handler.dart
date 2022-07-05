import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';

import 'native_method_caller.dart';

const int DEFAULT_RED_THRESHOLD = 246;

class EvaluationHandler {
  late Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();

  final _input = StreamController<CameraImage>();
  final _output = StreamController<PpgPoint>();

  Stream<PpgPoint> get outputStream => _output.stream;

  Future<dynamic> initialize() async {
    try {
      _isolate = await _createIsolate();

      _receivePort.listen((message) {
        if (message is SendPort) {
          _handleReceivedSendPort(message);
        } else if (message is PpgPoint) {
          _handleReceivedPpgPoint(message);
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

  void _handleReceivedPpgPoint(PpgPoint ppgPoint) {
    _output.add(ppgPoint);
  }

  void _handleReceivedAny(dynamic msg) {
    log("EvaluationHandler: unknown message: $msg");
  }

  static void _calibrate(SendPort sendPort) {
    log("EvaluationHandler: isolate started.");
    int redThreshold = DEFAULT_RED_THRESHOLD;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    final nativeMethodCaller = NativeMethodCaller();
    receivePort.listen((msg) {
      if (msg is int) {
        redThreshold = msg;
      } else if (msg is CameraImage) {
        PpgPoint? ppgPoint = nativeMethodCaller.evaluate(msg, redThreshold);
        if (ppgPoint != null) {
          sendPort.send(ppgPoint);
        }
      }
    });
  }

  void handleImage(CameraImage img) {
    _input.add(img);
  }

  _createIsolate() async {
    return Isolate.spawn(_calibrate, _receivePort.sendPort);
  }

  dispose() {
    _isolate.kill();
    _receivePort.close();
  }
}
