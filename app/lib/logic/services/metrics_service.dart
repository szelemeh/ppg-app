import 'dart:convert';

import 'package:ppg_hrv_app/logic/models/metrics_response.dart';
import 'package:ppg_hrv_app/logic/models/scan.dart';
import 'package:http/http.dart' as http;

const API = 'ppg-app-api.herokuapp.com';

class MetricsService {
  static Future<MetricsResponse> getMetrics(Scan scan) async {
    final url = Uri.https(API, 'metrics');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: scan.toJson(),
    );
    final data = json.decode(response.body);
    final r = MetricsResponse.fromMap(data);
    return r;
  }
}
