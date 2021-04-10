import 'package:flutter/material.dart';
import 'app.dart';

import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX

void test() {
  final DynamicLibrary nativeAddLib = Platform.isAndroid
      ? DynamicLibrary.open("libnative_add.so")
      : DynamicLibrary.process();

  final int Function(int x, int y) nativeAdd = nativeAddLib
      .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
      .asFunction();

  print("1 + 2 = ${nativeAdd(1, 2)}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  test();

  runApp(new App());
}
