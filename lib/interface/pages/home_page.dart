import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ppg_hrv_app/interface/pages/scan_page.dart';
import 'package:ppg_hrv_app/interface/widgets/graph.dart';
import 'package:ppg_hrv_app/logic/cubits/camera_scan/camera_scan_cubit.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PPG HRV Scanner"),
      ),
      body: BlocBuilder<CameraScanCubit, CameraScanState>(
          builder: (context, state) {
        if (state is ScanFinished) {
          return Chart(points: state.points);
        }
        return Center();
      }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => startScan(context),
          tooltip: 'Start scan',
          child: Icon(Icons.camera_alt)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void startScan(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ScanPage()));
  }
}
