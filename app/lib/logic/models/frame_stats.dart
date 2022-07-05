class FrameStats {
  final int redMax;
  final int redMin;

  FrameStats({required this.redMax, required this.redMin});

  @override
  String toString() => '(redMax: $redMax, redMin: $redMin)';
}
