part of 'ppg_points_cubit.dart';

@immutable
abstract class PpgPointsState {}

class PpgPointsInitial extends PpgPointsState {}

class PpgPointsLoading extends PpgPointsState {}

class PpgPointsNotLoaded extends PpgPointsState {}

class PpgPointsLoaded extends PpgPointsState {
  final List<PpgPoint> points;

  PpgPointsLoaded(this.points);
}
