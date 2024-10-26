import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/models/file_to_send.dart';

class SelectedFileInfoList {
  //fileName: fileName fileSize: fileSize
  final List<FileToSend> _selectedFileList;

  SelectedFileInfoList(this._selectedFileList);

  void add(FileToSend data) {
    _selectedFileList.add(data);
  }

  @override
  int get hashCode {
    int hash = 0;
    for (var file in _selectedFileList) {
      hash ^= file.hashCode; // 使用异或运算
      hash = (hash << 5) | (hash >> 27); // 左移5位并保持32位
    }
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SelectedFileInfoList) return false;

    // 比较列表中的内容
    return _selectedFileList.length == other._selectedFileList.length &&
        _selectedFileList
            .every((file) => other._selectedFileList.contains(file));
  }

  List<FileToSend> get selectedFileInfoList => _selectedFileList;

  // void setFileStatus(int index, SendFileStatus newStatus) {
  //   _selectedFileList[index].fileStatus = newStatus;
  // }

  bool get isEmpty => _selectedFileList.isEmpty;

  void removeAt(int index) {
    _selectedFileList.removeAt(index);
  }
}
