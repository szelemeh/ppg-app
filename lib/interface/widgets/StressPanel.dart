import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ppg_hrv_app/logic/cubits/metrics/metrics_cubit.dart';

class StressPanel extends StatelessWidget {
  final double stressLevel;

  const StressPanel({Key? key, required this.stressLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(builder: (context, state) {
      if (state is MetricsLoaded) {
        return Container(
          child: Column(children: [
            Text('Your stress level'),
            Container(
              height: 10,
            ),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 5.0,
              percent: state.response.stressIndex,
              center: new Text("26%"),
              progressColor: Colors.green,
            ),
          ]),
        );
      }
      return Container();
    });
  }
}
