import 'dart:typed_data';

import 'package:let_us_chat/core/constants/enums.dart';

class FileToSend {
  final int fileIndex;
  final String fileName;
  final int fileSize;
  SendFileStatus fileStatus;
  final Stream<List<int>>? fileData;
  double sendProgress;
  String? errorMsg;

  FileToSend({
    this.errorMsg,
    required this.fileIndex,
    required this.fileName,
    required this.fileSize,
    required this.fileStatus,
    required this.fileData,
    this.sendProgress = 0,
  });
  String getFixedFileSize() {
    double size = fileSize / (1000 * 1000);
    var selectedFileSize = size >= 1000
        ? '${((size) / 1000).toStringAsFixed(2)}GB'
        : size >= 1
            ? '${(size).toStringAsFixed(2)} MB'
            : '${(size * 1000).toStringAsFixed(2)} KB';
    return selectedFileSize;
  }
}
