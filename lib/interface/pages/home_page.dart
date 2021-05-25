import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ppg_hrv_app/interface/pages/scan_page.dart';
import 'package:ppg_hrv_app/interface/widgets/chart.dart';
import 'package:ppg_hrv_app/interface/widgets/metric_list.dart';
import 'package:ppg_hrv_app/logic/cubits/camera_scan/camera_scan_cubit.dart';
import 'package:ppg_hrv_app/logic/cubits/metrics/metrics_cubit.dart';
import 'package:ppg_hrv_app/logic/cubits/ppg_points/ppg_points_cubit.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final metricsCubit = BlocProvider.of<MetricsCubit>(context);
    final ppgPointsCubit = BlocProvider.of<PpgPointsCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("PPG HRV Scanner"),
      ),
      body: BlocBuilder<CameraScanCubit, CameraScanState>(
          builder: (context, state) {
        if (state is ScanFinished) {
          metricsCubit.loadMetrics(state.scan);
          ppgPointsCubit.normalizePpgPoints(state.scan.points);

          return Center(
            child: Column(
              children: [
                BlocBuilder<PpgPointsCubit, PpgPointsState>(
                  builder: (context, state) {
                    if (state is PpgPointsLoaded) {
                      return Container(
                        child: Chart(points: state.points),
                        height: 100.0,
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                MetricList()
              ],
            ),
          );
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
