import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ppg_hrv_app/logic/models/metric.dart';
import 'package:ppg_hrv_app/logic/models/metrics_response.dart';
import 'package:ppg_hrv_app/logic/models/scan.dart';
import 'package:ppg_hrv_app/logic/services/metrics_service.dart';

part 'metrics_state.dart';

class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit() : super(MetricsInitial());

  void loadMetrics(Scan scan) {
    emit(MetricsLoading());
    MetricsService.getMetrics(scan)
        .then((metrics) => emit(MetricsLoaded(metrics)))
        .catchError((e) => emit(MetricsNotLoaded()));
  }
}
