import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/frame_stats.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/ppg_value_calc.dart';

class PpgPointCalc {
  late final Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();
  final _results = StreamController<PpgPoint>();
  final _stats = StreamController<FrameStats>();
  late final SendPort _sendPort;
  bool calibration = true;
  bool _initialized = false;

  bool get initialized => _initialized;

  void initialize() async {
    try {
      _isolate = await Isolate.spawn(_computePpgPoint, _receivePort.sendPort);
      _receivePort.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          _initialized = true;
        } else if (message is PpgPoint) {
          _results.add(message);
        } else if (message is FrameStats) {
          _stats.add(message);
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Stream<PpgPoint> getResultsStream() {
    return _results.stream;
  }

  Stream<FrameStats> getFrameStatsStream() {
    return _stats.stream;
  }

  void addTask(CameraImage image) {
    if (initialized) {
      _sendPort.send(image);
    }
  }

  static void _computePpgPoint(SendPort sendPort) {
    print("Isolate started!");
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    final PpgValueCalc _valueCalc = PpgValueCalc();
    receivePort.listen((msg) {
      if (msg is CameraImage) {
        PpgPoint point = _valueCalc.evaluate(msg);
        sendPort.send(point);
      }
    });
  }

  static void _calibrate(SendPort sendPort) {
    print("Isolate started!");
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    final PpgValueCalc _valueCalc = PpgValueCalc();
    receivePort.listen((msg) {
      if (msg is CameraImage) {
        FrameStats stats = _valueCalc.getFrameStats(msg);
        sendPort.send(stats);
      }
    });
  }

  void dispose() {
    _results.close();
    _receivePort.close();
    _initialized = false;
    _isolate.kill();
  }
}
