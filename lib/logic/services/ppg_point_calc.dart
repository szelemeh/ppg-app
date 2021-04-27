import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/frame_stats.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/ppg_value_calc.dart';

class PpgPointCalc {
  late Isolate _isolate;
  final ReceivePort _computingReceivePort = ReceivePort();
  final ReceivePort _calibratingReceivePort = ReceivePort();
  final _results = StreamController<PpgPoint>();
  final List<FrameStats> frameStatsList = [];
  int redThreshold = 250;
  bool _calibration = true;
  late SendPort _sendPort;
  bool _initialized = false;

  bool get initialized => _initialized;

  void initialize() async {
    await startCalibratingIsolate();
    Future.delayed(Duration(seconds: 5), () async {
      _updateRedThreshold();
      _calibration = false;
      _initialized = false;
      _isolate.kill();
      await startComputingIsolate();
    });
  }

  startComputingIsolate() async {
    try {
      _isolate =
          await Isolate.spawn(_computePpgPoint, _computingReceivePort.sendPort);
      _computingReceivePort.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          _initialized = true;
          _sendPort.send(redThreshold);
        } else if (message is PpgPoint) {
          _results.add(message);
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  startCalibratingIsolate() async {
    try {
      _isolate =
          await Isolate.spawn(_calibrate, _calibratingReceivePort.sendPort);
      _calibratingReceivePort.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          _initialized = true;
        } else if (message is FrameStats) {
          frameStatsList.add(message);
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Stream<PpgPoint> getResultsStream() {
    return _results.stream;
  }

  void addTask(CameraImage image) {
    if (initialized) {
      if (_calibration)
        _sendPort.send(image);
      else
        _sendPort.send(image);
    }
  }

  static void _computePpgPoint(SendPort sendPort) {
    print("Isolate started!");
    int redThreshold = 250;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    final PpgValueCalc _valueCalc = PpgValueCalc();
    receivePort.listen((msg) {
      if (msg is int) {
        redThreshold = msg;
      } else if (msg is CameraImage) {
        PpgPoint point = _valueCalc.evaluate(msg, redThreshold);
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
    _calibratingReceivePort.close();
    _computingReceivePort.close();
    _initialized = false;
    _isolate.kill();
  }

  void _updateRedThreshold() {
    double maxSum = 0;
    double minSum = 0;
    for (final stats in frameStatsList) {
      maxSum += stats.redMax;
      minSum += stats.redMin;
    }
    double maxMean = maxSum / frameStatsList.length;
    double minMean = minSum / frameStatsList.length;
    try {
      redThreshold = (maxMean - 0.1 * (maxMean - minMean)).toInt();
    } catch (e) {
      redThreshold = 250;
    }
    print("red threshold is set to $redThreshold");
  }
}
