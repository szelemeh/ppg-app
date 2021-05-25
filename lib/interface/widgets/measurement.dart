import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ppg_hrv_app/interface/widgets/StressPanel.dart';
import 'package:ppg_hrv_app/interface/widgets/metric_list.dart';
import 'package:ppg_hrv_app/logic/cubits/ppg_points/ppg_points_cubit.dart';

import 'chart.dart';

class Measurement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [Text('12:58, May 25')],
            ),
            BlocBuilder<PpgPointsCubit, PpgPointsState>(
              builder: (context, state) {
                if (state is PpgPointsLoaded) {
                  return Container(
                    child: Chart(points: state.points),
                    height: 60.0,
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
            Text(''),
            StressPanel(stressLevel: 0.26),
            ExpansionTile(
              initiallyExpanded: false,
              title: Text('Details'),
              children: [MetricList()],
            ),
          ],
        ),
      ),
    );
  }
}
