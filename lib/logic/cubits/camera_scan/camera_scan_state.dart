part of 'camera_scan_cubit.dart';

@immutable
abstract class CameraScanState {}

class CameracubitInitial extends CameraScanState {}

class ScanStarted extends CameraScanState {
  final CameraController controller;
  ScanStarted({
    required this.controller,
  });
}

class ScanRunning extends CameraScanState {
  final int radius;
  final CameraController controller;
  ScanRunning({
    required this.controller,
    required this.radius,
  });
}

class ScanFinished extends CameraScanState {
  final Scan scan;

  ScanFinished({
    required this.scan,
  });
}
