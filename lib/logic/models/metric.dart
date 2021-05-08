import 'dart:convert';

class Metric {
  final String type;
  final int value;

  Metric(this.type, this.value);

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
    };
  }

  factory Metric.fromMap(Map<String, dynamic> map) {
    return Metric(
      map['type'],
      map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Metric.fromJson(String source) => Metric.fromMap(json.decode(source));
}
