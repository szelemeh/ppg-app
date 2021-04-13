import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'dart:math';

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
    final data = LineChartData(
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (value) => const TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 16),
            getTitles: (value) {
              int show = (value ~/ 1000);
              if (prev == show) {
                return '';
              } else {
                prev = show;
                return show.toString();
              }
            },
            margin: 8,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: points
                .map((p) => FlSpot(p.timestamp.toDouble(), p.value.toDouble()))
                .toList(),
            isCurved: true,
            colors: gradientColors,
            barWidth: 2,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(data),
    );
  }
}
