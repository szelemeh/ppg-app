class PpgPoint {
  final int timestamp;
  final int value;

  PpgPoint({required this.timestamp, required this.value});

  @override
  String toString() => '(x: $timestamp, y: $value)';
}
