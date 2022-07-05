import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ppg_hrv_app/logic/models/ppg_point.dart';
import 'package:ppg_hrv_app/logic/services/ppg_points_service.dart';

part 'ppg_points_state.dart';

class PpgPointsCubit extends Cubit<PpgPointsState> {
  PpgPointsCubit() : super(PpgPointsInitial());

  void normalizePpgPoints(List<PpgPoint> points) {
    emit(PpgPointsLoading());
    PpgPointsService.normalizePoints(points)
        .then((normalizedPoints) => emit(PpgPointsLoaded(normalizedPoints)))
        .catchError((e) {
      print('normalizePpgPoints $e');
      log('normalizePoints', error: e);
      emit(PpgPointsNotLoaded());
    });
  }
}
