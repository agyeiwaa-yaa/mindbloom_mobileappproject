import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> persistJournalImage(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      return sourcePath;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'journal_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final fileName = 'journal_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destination = p.join(imagesDir.path, fileName);
    final copiedFile = await sourceFile.copy(destination);
    return copiedFile.path;
  }

  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }
}
