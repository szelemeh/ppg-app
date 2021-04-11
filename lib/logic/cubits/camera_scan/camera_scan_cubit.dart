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
  CameraScanCubit() : super(CameracubitInitial());

  void startScan() async {
    List<CameraDescription> cameras = await availableCameras();
    final controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    calc.initialize();
    calc.getResultsStream().listen((ppgPoint) {
      ppgPointList.add(ppgPoint);
    });
    controller.startImageStream((image) {
      calc.addTask(image);
    });
    controller.setFlashMode(FlashMode.torch);
    emit(ScanStarted(controller: controller));
  }

  void stopScan() {
    if (state is ScanStarted) {
      final currentState = state as ScanStarted;
      currentState.controller.setFlashMode(FlashMode.off);
      if (currentState.controller.value.isStreamingImages) {
        currentState.controller.stopImageStream();
      }
      calc.dispose();
      int initialTime = ppgPointList[0].timestamp;
      final shifted = ppgPointList
          .map((p) => PpgPoint(
              timestamp: (p.timestamp - initialTime), value: p.value))
          .toList();
      emit(ScanFinished(points: shifted));
    }
  }
}
