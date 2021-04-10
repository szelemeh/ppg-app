import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/ppg_value_calc.dart';

class PpgPointCalc {
  late final Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();
  StreamController<PpgPoint> _results = StreamController<PpgPoint>();
  late final SendPort _sendPort;
  bool _initialized = false;

  bool get initialized => _initialized;

  void initialize() async {
    try {
      _isolate = await Isolate.spawn(_computePpgPoint, _receivePort.sendPort);
      _receivePort.listen((message) {
        if (message is SendPort) {
          _sendPort = message;
          print("sendPort is now ready!");
        } else if (message is PpgPoint) {
          _results.add(message);
        }
      });
      _initialized = true;
    } catch (e) {
      print("Error: $e");
    }
  }

  Stream<PpgPoint> getResultsStream() {
    return _results.stream;
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
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        int value = _valueCalc.calculate(msg);
        sendPort.send(
          PpgPoint(
            timestamp: timestamp,
            value: value,
          ),
        );
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
