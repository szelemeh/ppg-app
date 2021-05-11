import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ppg_hrv_app/interface/widgets/metric_view.dart';
import 'package:ppg_hrv_app/logic/cubits/metrics/metrics_cubit.dart';

class MetricList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetricsCubit, MetricsState>(builder: (context, state) {
      if (state is MetricsLoaded) {
        List<Widget> metrics = state.metrics
            .map(
              (metric) => MetricView(data: metric),
            )
            .toList();
        return Center(
          child: Column(
            children: metrics,
          ),
        );
      } else
        return Center(
          child: CircularProgressIndicator(),
        );
    });
  }
}
