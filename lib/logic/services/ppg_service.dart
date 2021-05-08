import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ppg_hrv_app/logic/models/frame_stats.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/calibration_handler.dart';
import 'package:ppg_hrv_app/logic/services/evaluation_handler.dart';

const int DEFAULT_RED_THRESHOLD = 246;
const int CALIBRATION_TIME = 5;

enum PpgServiceState { notInitialized, initialized, calibration, evaluation }

class PpgService {
  final _results = StreamController<PpgPoint>();
  late CalibrationHandler _calibrationHandler;
  late EvaluationHandler _evaluationHandler;
  final List<FrameStats> frameStatsList = [];
  int redThreshold = DEFAULT_RED_THRESHOLD;
  late final CameraController _controller;
  PpgServiceState _state = PpgServiceState.notInitialized;

  CameraController get cameraController => _controller;

  initialize() async {
    if (_state == PpgServiceState.notInitialized) {
      List<CameraDescription> cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.jpeg);
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
      }
    }
  }

  start() async {
    await _startCalibratingIsolate();
    Future.delayed(Duration(seconds: CALIBRATION_TIME), () async {
      _updateRedThreshold();
      _state = PpgServiceState.evaluation;
      await _startComputingIsolate();
    });
    _controller.startImageStream((image) {
      _addTask(image);
    });
    _controller.setFlashMode(FlashMode.torch);
  }

  stop() {
    _controller.setFlashMode(FlashMode.off);
    if (_controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }
  }

  _startComputingIsolate() async {
    _evaluationHandler = EvaluationHandler();
    try {
      await _evaluationHandler.initialize();
      _evaluationHandler.outputStream
          .listen((ppgPoint) => _results.add(ppgPoint));
    } catch (error) {
      log('PpgService: error starting evaluation handler: $error');
    }
  }

  _startCalibratingIsolate() async {
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

  void _addTask(CameraImage img) {
    switch (_state) {
      case PpgServiceState.calibration:
        _calibrationHandler.handleImage(img);
        break;
      case PpgServiceState.evaluation:
        _evaluationHandler.handleImage(img);
        break;
      default:
        break;
    }
  }

  void dispose() {
    _results.close();
    _calibrationHandler.dispose();
    _evaluationHandler.dispose();
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
