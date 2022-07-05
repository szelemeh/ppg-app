import 'dart:convert';

class PpgPoint {
  final int timestamp;
  final double value;

  PpgPoint({
    required this.timestamp,
    required this.value,
  });

  @override
  String toString() => 'PpgPoint(timestamp: $timestamp, value: $value)';

  PpgPoint copyWith({
    int? timestamp,
    double? value,
  }) {
    return PpgPoint(
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'value': value,
    };
  }

  factory PpgPoint.fromMap(Map<String, dynamic> map) {
    return PpgPoint(
      timestamp: map['timestamp'],
      value: map['value'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PpgPoint.fromJson(String source) => PpgPoint.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is PpgPoint &&
      other.timestamp == timestamp &&
      other.value == value;
  }

  @override
  int get hashCode => timestamp.hashCode ^ value.hashCode;
}
