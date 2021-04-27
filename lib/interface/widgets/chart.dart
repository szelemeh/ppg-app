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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(data),
    );
  }

  LineChartData getData() {
    int max = -1;
    int min = 10000;
    for (final point in points) {
      print(point);
      if (point.value > max) max = point.value;
      if (point.value < min) min = point.value;
    }
    final averaged = <PpgPoint>[];
    for (int i = 0; i < points.length - 2; i+=3) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = points[i + 2];
      averaged.add(PpgPoint(
          timestamp: (p1.timestamp + p2.timestamp+ p3.timestamp) ~/ 3,
          value: (p1.value + p2.value+ p3.value) ~/ 3));
    }

    final newPoints = averaged
        .map((e) => PpgPoint(timestamp: e.timestamp, value: max - e.value))
        .toList();

    return LineChartData(
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
            spots: newPoints
                .map((p) => FlSpot(p.timestamp.toDouble(), p.value.toDouble()))
                .toList(),
            isCurved: true,
            colors: gradientColors,
            barWidth: 2,
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
