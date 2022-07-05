import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';

class Chart extends StatelessWidget {
  final List<PpgPoint> points;
  int prev = -1;
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  Chart({Key? key, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = getData();
    return LineChart(data);
  }

  LineChartData getData() {

    return LineChartData(
      gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points
                .map((p) => FlSpot(p.timestamp.toDouble(), p.value.toDouble()))
                .toList(),
            isCurved: true,
            colors: gradientColors,
            barWidth: 1,
            curveSmoothness: 0.35,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: false,
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ]);
  }
}
