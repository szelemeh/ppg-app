import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ppg_hrv_app/logic/cubits/camera_scan/camera_scan_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(new MultiBlocProvider(
    providers: getBlocProviders(),
    child: App(),
  ));
}

List<BlocProvider> getBlocProviders() {
  return [
    BlocProvider<CameraScanCubit>(create: (context) => CameraScanCubit()),
  ];
}
