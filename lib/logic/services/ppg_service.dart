import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/frame_stats.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/calibration_handler.dart';
import 'package:ppg_hrv_app/logic/services/evaluation_handler.dart';
import 'package:ppg_hrv_app/logic/services/native_method_caller.dart';

const int DEFAULT_RED_THRESHOLD = 246;

class PpgService {
  late Isolate _isolate;
  final _results = StreamController<PpgPoint>();
  late final CalibrationHandler _calibrationHandler;
  late final EvaluationHandler _evaluationHandler;
  final List<FrameStats> frameStatsList = [];
  int redThreshold = DEFAULT_RED_THRESHOLD;
  bool _calibration = true;

  void initialize() async {
    await startCalibratingIsolate();
    Future.delayed(Duration(seconds: 5), () async {
      _updateRedThreshold();
      _calibration = false;
      await startComputingIsolate();
    });
  }

  startComputingIsolate() async {
    _evaluationHandler = EvaluationHandler();
    try {
      await _evaluationHandler.initialize();
      _evaluationHandler.outputStream
          .listen((ppgPoint) => _results.add(ppgPoint));
    } catch (error) {
      log('PpgService: error starting evaluation handler: $error');
    }
  }

  startCalibratingIsolate() async {
    _calibrationHandler = CalibrationHandler();
    try {
      await _calibrationHandler.initialize();
      _calibrationHandler.outputStream
          .listen((frameStats) => frameStatsList.add(frameStats));
    } catch (error) {
      log('PpgService: error starting calibration handler: $error');
    }
  }

  Stream<PpgPoint> getResultsStream() {
    return _results.stream;
  }

  void addTask(CameraImage img) {
      if (_calibration)
        _calibrationHandler.addImage(img);
      else
        _evaluationHandler.addImage(img);
  }

  void dispose() {
    _results.close();
    _calibrationHandler.dispose();
    _evaluationHandler.dispose();
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
      redThreshold = (maxMean - 0.15 * (maxMean - minMean)).toInt();
    } catch (e) {
      redThreshold = DEFAULT_RED_THRESHOLD;
    }
    log("PpgService: red threshold is set to $redThreshold");
  }
}
