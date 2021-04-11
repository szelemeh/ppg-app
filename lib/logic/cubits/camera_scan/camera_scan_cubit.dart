import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/ppg_point_calc.dart';

part 'camera_scan_state.dart';

class CameraScanCubit extends Cubit<CameraScanState> {
  final List<PpgPoint> ppgValueList = [];
  final PpgPointCalc calc = PpgPointCalc();
  CameraScanCubit() : super(CameracubitInitial());

  void startScan() async {
    List<CameraDescription> cameras = await availableCameras();
    final controller = CameraController(cameras[0], ResolutionPreset.low);
    await controller.initialize();
    calc.initialize();
    calc.getResultsStream().listen((ppgPoint) {
      ppgValueList.add(ppgPoint);
    });
    controller.startImageStream((image) {
      calc.addTask(image);
    });
    emit(ScanStarted(controller: controller));
  }

  void stopScan() {
    if (state is ScanStarted) {
      final currentState = state as ScanStarted;
      if (currentState.controller.value.isStreamingImages) {
        currentState.controller.stopImageStream();
      }
      calc.dispose();
      print(ppgValueList);
    }
  }
}
