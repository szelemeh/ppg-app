import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ppg_hrv_app/interface/pages/home_page.dart';
import 'package:ppg_hrv_app/logic/cubits/camera_scan/camera_scan_cubit.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: getBlocProviders(),
        child: HomePage(),
      ),
    );
  }

  List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<CameraScanCubit>(create: (context) => CameraScanCubit()),
    ];
  }
}
