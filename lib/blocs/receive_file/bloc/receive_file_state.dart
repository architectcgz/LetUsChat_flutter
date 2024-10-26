part of 'receive_file_bloc.dart';

sealed class ReceiveFileState {
  const ReceiveFileState();
}

final class ReceiveFileInitial extends ReceiveFileState {}

final class ReceivingFileSlice extends ReceiveFileState {
  final int chunkIndex;
  final int totalChunks;

  ReceivingFileSlice({required this.chunkIndex, required this.totalChunks});
}

final class MergingFileChunks extends ReceiveFileState{

}

final class FileChunksMerged extends ReceiveFileState{}

final class FileSaved extends ReceiveFileState{
  final String fileDirPath;

  FileSaved({required this.fileDirPath});

}