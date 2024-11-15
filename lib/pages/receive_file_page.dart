import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/blocs/receive_file/bloc/receive_file_bloc.dart';

import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiveFilePage extends StatefulWidget {
  final String friendUid;
  final List<Map<String, String>> fileList;
  final int fileListHashCode;
  const ReceiveFilePage({
    Key? key,
    required this.friendUid,
    required this.fileList,
    required this.fileListHashCode,
  }) : super(key: key);

  @override
  State<ReceiveFilePage> createState() => _ReceiveFilePageState();
}

class _ReceiveFilePageState extends State<ReceiveFilePage> {
  late List<Map<String, String>> _fileList;
  bool _accepted = false;
  final WebSocketService _webSocketService =
      serviceLocator.get<WebSocketService>();
  final _globalUser = serviceLocator.get<GlobalUserBloc>().globalUser!;
  double _progress = 0.0;
  String _fileStatus = "尚未开始接收";
  String? _fileStoragePath;
  @override
  void initState() {
    _fileList = widget.fileList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithTitleAndArrow(
        title: "在线接收文件",
        centerTitle: true,
      ),
      body: BlocListener<ReceiveFileBloc, ReceiveFileState>(
        listener: (context, state) {
          if (state is ReceivingFileSlice) {
            setState(() {
              _fileStatus = "正在接收";
              _progress = (state.chunkIndex+1) / state.totalChunks;
            });
          } else if (state is MergingFileChunks) {
            setState(() {
              _fileStatus = "合并文件中";
            });
          } else if (state is FileChunksMerged) {
            setState(() {
              _fileStatus = "文件合并完成,开始保存文件";
            });
          } else if (state is FileSaved) {
            setState(() {
              _fileStatus = "文件保存成功";
              _fileStoragePath = "文件已保存到:${context.read<ReceiveFileBloc>().fileTempDir}";
            });
          }
        },
        child: Column(
          children: [
            Text(
              "文件列表如下,共${_fileList.length}个文件",
              style: const TextStyle(fontSize: 16),
            ),
            Text("文件校验码: ${widget.fileListHashCode},请注意与好友的文件校验码比对"),
            _fileStoragePath!=null?Text(_fileStoragePath!):const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Material(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _fileList.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title:
                                  Text("文件名: ${_fileList[index]['fileName']!}"),
                              subtitle:
                                  Text("文件大小: ${_fileList[index]['fileSize']!}"),
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 100, // 设置进度条的宽度
                                child: LinearProgressIndicator(
                                  value: _progress, // 替换为实际进度值
                                ),
                              ),
                              Text("${(_progress * 100).toStringAsFixed(2)}%"),
                              Text("文件状态: $_fileStatus")
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: _accepted
                  ? null
                  : () {
                      print("接受");
                      setState(() {
                        _accepted = true;
                      });
                      //这里的hashCode是本地计算的来的
                      print("此次接收的文件hashCode: ${widget.fileListHashCode}");
                      _webSocketService.sendAcceptFileRequest(widget.friendUid,
                          _globalUser.userId, widget.fileListHashCode);
                    },
              child: _accepted ? const Text("已接受") : const Text("接受"),
            )
          ],
        ),
      ),
    );
  }
}
