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
