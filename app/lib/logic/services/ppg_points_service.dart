import 'dart:convert';

import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:http/http.dart' as http;

const API = 'ppg-app-api.herokuapp.com';

class PpgPointsService {
  static Future<List<PpgPoint>> normalizePoints(List<PpgPoint> points) async {
    final url = Uri.https(API, 'ppg-points');
    final bodyMap = {
      'ppgPoints': points.map((p) => p.toMap()).toList(),
      'normalizationDegree': 2
    };
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(bodyMap),
    );
    final data = json.decode(response.body);
    List<PpgPoint> normalizedPoints = data['ppgPoints']
        .map<PpgPoint>((pointMap) => PpgPoint.fromMap(pointMap))
        .toList();
    return normalizedPoints;
  }
}
