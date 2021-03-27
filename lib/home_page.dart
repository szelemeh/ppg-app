import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_page.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CameraPage(cameras: cameras))),
                child: Text("Start Scan"))
          ],
        ),
      ),
    );
  }
}
