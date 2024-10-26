import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/models/file_slice.dart';
import 'package:path_provider/path_provider.dart';

part 'receive_file_event.dart';
part 'receive_file_state.dart';

class ReceiveFileBloc extends Bloc<ReceiveFileEvent, ReceiveFileState> {
  final Map<String, int> _totalChunks = {};
  final Map<String, String> _tempFilePaths = {};
  String? fileTempDir;
  void _saveFileChunk(String senderId,String fileName, int chunkIndex, List<int> chunkData,
      int totalChunks) async {
    // 如果还没有初始化该文件的临时文件路径
    if (!_tempFilePaths.containsKey(fileName)) {
      String tempFilePath = await _getTempFilePath(senderId,fileName);
      _tempFilePaths[fileName] = tempFilePath;
      _totalChunks[fileName] = totalChunks;
      // 确保目录存在
      _ensureDirectoryExists(tempFilePath);
      // 初始化文件以便写入
      print("初始化文件以便写入");
      File(tempFilePath).createSync(); // 创建文件
    }

    // 将分片写入临时文件
    File tempFile = File(_tempFilePaths[fileName]!);
    tempFile.writeAsBytesSync(chunkData, mode: FileMode.append);
  }

  void _ensureDirectoryExists(String filePath) {
    final directory = Directory(filePath).parent;
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print("路径$filePath不存在,已创建");
    }
  }

  Future<String> _getTempFilePath(String senderId,String fileName) async {
    // 生成一个临时文件路径
    var tempDir = await getApplicationDocumentsDirectory();
    fileTempDir = '${tempDir.path}/receivedFile/$senderId/$fileName';
    return fileTempDir!;
  }

  ReceiveFileBloc() : super(ReceiveFileInitial()) {

    on<ReceiveFileSlice>((event, emit) {
      var fileSlice = event.fileSlice;
      String fileName = fileSlice.fileName;
      String senderId = fileSlice.senderId;
      int chunkIndex = fileSlice.chunkIndex;
      int totalChunks = fileSlice.totalChunks;
      List<int> chunkData = fileSlice.chunkData;
      print("开始处理第$chunkIndex/$totalChunks个分片");
      emit(
          ReceivingFileSlice(chunkIndex: chunkIndex, totalChunks: totalChunks));
      // 保存分片
      print("将第$chunkIndex/$totalChunks个分片保存到文件");
      _saveFileChunk(senderId,fileName, chunkIndex, chunkData, totalChunks);

      // 检查是否接收到所有分片
      if (chunkIndex+ 1 == totalChunks) {
        print("所有分片已接收");
        print("文件保存完成");
        emit(FileChunksMerged());
        emit(FileSaved(
          fileDirPath: fileTempDir!
        ));
        fileTempDir = null;
      }
    });
  }
}
