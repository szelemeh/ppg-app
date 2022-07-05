import 'dart:convert';

class Metric {
  final String type;
  final int value;
  final bool? rating;

  Metric(this.type, this.value, this.rating);

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'rating': rating,
    };
  }

  factory Metric.fromMap(Map<String, dynamic> map) {
    return Metric(
      map['type'],
      map['value'],
      map['rating'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Metric.fromJson(String source) => Metric.fromMap(json.decode(source));
}
