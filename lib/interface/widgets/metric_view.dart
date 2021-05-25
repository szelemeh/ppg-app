import 'package:flutter/material.dart';
import 'package:ppg_hrv_app/logic/models/metric.dart';

class MetricView extends StatelessWidget {
  final Metric data;

  const MetricView({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: getColor(),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        children: [
          Expanded(child: Text(getDisplayName())),
          Expanded(child: Text(data.value.toString())),
          Expanded(child: Text(getDisplayUnit())),
        ],
      ),
    );
  }

  getColor() {
    switch (data.rating) {
      case true:
        return Colors.green[200];
      case false:
        return Colors.deepOrange[200];
      default:
        return Colors.grey[200];
    }
  }

  getDisplayUnit() {
    switch (data.type) {
      case 'heartRate':
        return 'beats/min';
      case 'pNN50':
      case 'Amo':
        return '%';
      case 'NN50':
        return 'times';
      default:
        return 'ms';
    }
  }

  getDisplayName() {
    switch (data.type) {
      case 'heartRate':
        return 'Heart rate';
      case 'sdnn':
        return 'SDNN';
      default:
        return data.type;
    }
  }
}
