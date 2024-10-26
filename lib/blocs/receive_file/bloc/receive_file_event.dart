part of 'receive_file_bloc.dart';

sealed class ReceiveFileEvent {
  const ReceiveFileEvent();
}

final class ReceiveFileSlice extends ReceiveFileEvent {
  final FileSlice fileSlice;

  ReceiveFileSlice({required this.fileSlice});
}
