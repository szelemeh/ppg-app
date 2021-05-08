part of 'metrics_cubit.dart';

@immutable
abstract class MetricsState {}

class MetricsInitial extends MetricsState {}

class MetricsLoading extends MetricsState {}

class MetricsNotLoaded extends MetricsState {}

class MetricsLoaded extends MetricsState {
  final List<Metric> metrics;

  MetricsLoaded(this.metrics);
}
