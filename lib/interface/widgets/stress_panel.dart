import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ppg_hrv_app/logic/cubits/metrics/metrics_cubit.dart';

enum StressLevel { low, optimal, medium, high }

class StressPanel extends StatelessWidget {
  const StressPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(builder: (context, state) {
      if (state is MetricsLoaded) {
        final stressIndex = state.response.stressIndex;
        final stressLevel = determineStressLevel(stressIndex);
        final color = determineColor(stressLevel);
        return Container(
          child: Column(children: [
            Text('Your stress index is ${state.response.stressIndex.toInt()}'),
            Container(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Stress level is '),
                Text(buildStressLevelText(stressLevel),
                    style: TextStyle(color: color))
              ],
            )
          ]),
        );
      }
      return Container();
    });
  }

  determineColor(StressLevel stressLevel) {
    switch (stressLevel) {
      case StressLevel.low:
        return Colors.orange;
      case StressLevel.optimal:
        return Colors.green;
      case StressLevel.medium:
        return Colors.orange;
      case StressLevel.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  determineStressLevel(stressIndex) {
    if (stressIndex < 20) return StressLevel.low;
    if (stressIndex < 120) return StressLevel.optimal;
    if (stressIndex < 400) return StressLevel.medium;
    return StressLevel.high;
  }

  buildStressLevelText(StressLevel stressLevel) {
    String adj = 'unknwon';
    if (stressLevel == StressLevel.low) adj = 'too low';
    if (stressLevel == StressLevel.optimal) adj = 'optimal';
    if (stressLevel == StressLevel.medium) adj = 'medium';
    if (stressLevel == StressLevel.high) return 'too high';
    return adj;
  }
}
