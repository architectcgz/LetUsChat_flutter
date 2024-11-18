import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

import '../blocs/receive_file/receive_file_bloc.dart';


class ReceiveFilePage extends StatefulWidget {
  final String friendUid;
  final List<Map<String, dynamic>> fileList;
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
  late List<Map<String, dynamic>> _fileList;//有三个键 fileName,fileSize,progress,分别表示文件名,文件大小,文件接收进度
  bool _accepted = false;
  final WebSocketService _webSocketService =
      serviceLocator.get<WebSocketService>();
  final _globalUser = serviceLocator.get<GlobalUserBloc>().globalUser!;
  String? _fileStoragePath;
  late bool _oneReceived;
  @override
  void initState() {
    _fileList = widget.fileList;
    for(var item in _fileList){
      item['fileStatus'] = "尚未接收";
      item['progress'] = 0.0;
    }
    _oneReceived = false;
    context.read<ReceiveFileBloc>().add(ReceiveFileRequestEvent(fileNum:_fileList.length));
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
              _fileList[state.fileIndex]['fileStatus'] = "正在接收";
              _fileList[state.fileIndex]['progress'] = (state.chunkIndex+1) / state.totalChunks;
            });
          } else if (state is MergingFileChunks) {
            setState(() {
              _fileList[state.fileIndex]['fileStatus'] = "合并文件中";
            });
          } else if (state is FileChunksMerged) {
            setState(() {
              _fileList[state.fileIndex]['fileStatus'] = "文件合并完成,开始保存文件";
            });
          } else if (state is FileSaved) {
            setState(() {
              _oneReceived = true;
              _fileList[state.fileIndex]['fileStatus'] = "文件保存成功";
            });
            if(state.fileIndex + 1 == _fileList.length){
              setState(() {
                _fileStoragePath = "文件已保存到:${state.fileDirPath}";
              });
            }
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
                                  value:_fileList[index]["progress"]as double??0, // 替换为实际进度值
                                ),
                              ),
                              Text("${((_fileList[index]['progress']as double)*100).toStringAsFixed(2)}%"),
                              Text("文件状态: ${_fileList[index]["fileStatus"]}")
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                ),
                // TextButton(onPressed: (){
                //   if(!_oneReceived){
                //     ShowWidgetUtil.showSnackBar(context, "请等待至少一个文件保存成功");
                //   }
                // }, child: const Text("打开文件保存位置"))
              ],
            ),

          ],
        ),
      ),
    );
  }
}
