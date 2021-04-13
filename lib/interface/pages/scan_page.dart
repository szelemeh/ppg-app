import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ppg_hrv_app/logic/cubits/camera_scan/camera_scan_cubit.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late final CameraScanCubit scanCubit;

  @override
  Widget build(BuildContext context) {
    scanCubit = BlocProvider.of<CameraScanCubit>(context);
    scanCubit.startScan();
    return Scaffold(
        body: BlocBuilder(
      bloc: scanCubit,
      builder: (context, state) {
        if (state is ScanStarted) {
          return MaterialApp(
            home: CameraPreview(
              state.controller,
            ),
          );
        } else if (state is ScanRunning) {
          return MaterialApp(
              home: CameraPreview(
            state.controller,
            child: Center(
              child: Text(
                state.radius.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ));
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ));
  }

  @override
  void dispose() {
    scanCubit.stopScan();
    super.dispose();
  }
}
