import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';

class Chart extends StatelessWidget {
  final List<PpgPoint> points;

  const Chart({Key? key, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = LineChartData(lineBarsData: [
      LineChartBarData(
          spots: points
              .map((p) => FlSpot(p.timestamp.toDouble(), p.value.toDouble()))
              .toList())
    ]);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(data),
    );
  }
}
