import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StressPanel extends StatelessWidget {
  final double stressLevel;

  const StressPanel({Key? key, required this.stressLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Optimal stress level'),
          Container(height: 10,),
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 5.0,
            percent: stressLevel,
            center: new Text("26%"),
            progressColor: Colors.green,
          )
        ],
      ),
    );
  }
}
