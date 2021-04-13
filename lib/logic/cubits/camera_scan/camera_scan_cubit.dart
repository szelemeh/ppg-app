import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/ppg_point_calc.dart';
import 'package:image/image.dart';

part 'camera_scan_state.dart';

class CameraScanCubit extends Cubit<CameraScanState> {
  final List<PpgPoint> ppgPointList = [];
  final PpgPointCalc calc = PpgPointCalc();
  late final CameraController controller;
  CameraScanCubit() : super(CameracubitInitial());

  void startScan() async {
    List<CameraDescription> cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    if (!controller.value.isInitialized) {
      await controller.initialize();
    }
    calc.initialize();
    calc.getResultsStream().listen((ppgPoint) {
      ppgPointList.add(ppgPoint);
      emit(ScanRunning(radius: ppgPoint.value, controller: controller));
    });
    controller.startImageStream((image) {
      calc.addTask(image);
    });
    // controller.setFlashMode(FlashMode.torch);
    emit(ScanStarted(controller: controller));
  }

  void stopScan() {
    if (state is ScanRunning) {
      controller.setFlashMode(FlashMode.off);
      if (controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
      calc.dispose();
      int initialTime = ppgPointList[0].timestamp;
      List<PpgPoint> shifted = ppgPointList
          .map((p) =>
              PpgPoint(timestamp: (p.timestamp - initialTime), value: p.value))
          .toList();
      int part = shifted.length ~/ 10;
      shifted = shifted.getRange(part, shifted.length - part).toList();
      emit(ScanFinished(points: shifted));
    }
  }
}
