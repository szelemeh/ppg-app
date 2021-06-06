import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/models/scan.dart';
import 'package:ppg_hrv_app/logic/services/ppg_service.dart';

part 'camera_scan_state.dart';

class CameraScanCubit extends Cubit<CameraScanState> {
  final List<PpgPoint> ppgPointList = [];
  late PpgService ppgService;

  CameraScanCubit() : super(CameracubitInitial());

  void startScan() async {
    ppgService = PpgService();
    ppgPointList.clear();
    await ppgService.initialize();
    await ppgService.start();
    ppgService.getResultsStream().listen((ppgPoint) {
      ppgPointList.add(ppgPoint);
      emit(ScanRunning(
          radius: ppgPoint.value, controller: ppgService.cameraController));
    });
    emit(ScanStarted(controller: ppgService.cameraController));
  }

  void stopScan() {
    if (state is ScanRunning || state is ScanStarted) {
      ppgService.stop();
      ppgService.dispose();
      emit(ScanFinished(scan: Scan(ppgPointList, 20)));
    }
  }
}
