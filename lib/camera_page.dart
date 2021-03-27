import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ppg_hrv_app/main.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState(cameras);
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  final List<CameraDescription> cameras;

  _CameraPageState(this.cameras);

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    compute(controller).then((o) => print("finished"));

    return MaterialApp(
      home: CameraPreview(controller),
    );
  }

  Future<void> compute(CameraController controller) async {
    await controller.startImageStream(
      (image) {
        final plane = image.planes[0];
        final counts = HashMap<int, int>();
        plane.bytes.forEach((byte) {
          if (counts[byte] == null) {
            counts[byte] = 0;
          }
          counts[byte] = counts[byte]! + 1;
        });
        int key = -1;
        int val = -1;
        counts.entries.forEach((MapEntry entry) {
          if (val < entry.value) {
            val = entry.value;
            key = entry.key;
          }
        });
        print("Most frequent value($val) is $key");
      },
    );
  }
}
