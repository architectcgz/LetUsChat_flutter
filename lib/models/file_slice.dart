class FileSlice {
  final String fileName;
  final String senderId;
  final int chunkIndex;
  final int totalChunks;
  final List<int> chunkData;

  FileSlice(
      {required this.fileName,
      required this.senderId,
      required this.chunkIndex,
      required this.totalChunks,
      required this.chunkData});
}
