import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileWriter {
  static Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static Future<File> _getLocalFile(path) async {
    final localPath = await _localPath;
    print("SAVED $localPath");
    return File('$localPath/$path');
  }

  static Future writeBytesToFile(Uint8List bytes, path) async {
    final file = await _getLocalFile(path);
    await file.writeAsBytes(bytes.toList());
  }
}
