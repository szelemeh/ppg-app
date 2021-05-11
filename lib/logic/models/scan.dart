import 'dart:convert';

import 'package:ppg_hrv_app/logic/models/ppg_point.dart';

class Scan {
  final List<PpgPoint> points;
  final int age;

  Scan(this.points, this.age);

  Map<String, dynamic> toMap() {
    return {
      'ppgPoints': points.map((x) => x.toMap()).toList(),
      'age': age
    };
  }

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      List<PpgPoint>.from(map['ppgPoints']?.map((x) => PpgPoint.fromMap(x))),
      map['age']
    );
  }

  String toJson() => json.encode(toMap());

  factory Scan.fromJson(String source) => Scan.fromMap(json.decode(source));
}
