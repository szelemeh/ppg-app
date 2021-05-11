import 'dart:convert';

import 'package:ppg_hrv_app/logic/models/metric.dart';
import 'package:ppg_hrv_app/logic/models/scan.dart';
import 'package:http/http.dart' as http;

const API = 'ppg-app-api.herokuapp.com';

class MetricsService {
  static Future<List<Metric>> getMetrics(Scan scan) async {
    final url = Uri.https(API, 'metrics');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: scan.toJson(),
    );
    final data = json.decode(response.body);
    List<Metric> metrics = data['metrics'].map<Metric>((metricMap) => Metric.fromMap(metricMap)).toList();
    return metrics;
  }
}
