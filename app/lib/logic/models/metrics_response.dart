import 'dart:convert';

import 'package:ppg_hrv_app/logic/models/metric.dart';

class MetricsResponse {
  final List<Metric> metrics;
  final double stressIndex;

  MetricsResponse(this.metrics, this.stressIndex);

  Map<String, dynamic> toMap() {
    return {
      'metrics': metrics.map((x) => x.toMap()).toList(),
      'stressIndex': stressIndex,
    };
  }

  factory MetricsResponse.fromMap(Map<String, dynamic> map) {
    return MetricsResponse(
      List<Metric>.from(map['metrics']?.map((x) => Metric.fromMap(x))),
      map['si'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MetricsResponse.fromJson(String source) =>
      MetricsResponse.fromMap(json.decode(source));
}
