import 'package:flutter/material.dart';
import 'package:ppg_hrv_app/logic/models/metric.dart';

class MetricView extends StatelessWidget {
  final Metric data;

  const MetricView({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(8),
      color: data.rating ? Colors.green[200] : Colors.deepOrange[200],
      child: Row(
        children: [
          Expanded(child: Text(getDisplayName())),
          Expanded(child: Text(data.value.toString())),
        ],
      ),
    );
  }

  getDisplayName() {
    switch (data.type) {
      case 'heartRate':
        return 'Heart rate';
      case 'sdnn':
        return 'SDNN';
      default:
        return 'Unknown metric';
    }
  }
}
