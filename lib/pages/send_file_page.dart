import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/blocs/send_file/send_file_bloc.dart';
import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/core/utils/file_transform_util.dart';

import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/models/file_to_send.dart';
import 'package:let_us_chat/models/selected_file_list.dart';
import 'package:let_us_chat/pages/utils/platform_utils.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

class SendFilePage extends StatefulWidget {
  final String friendUid;
  const SendFilePage({
    Key? key,
    required this.friendUid,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendFilePageState();
}

class _SendFilePageState extends State<SendFilePage> {
  final WebSocketService _webSocketService =
      serviceLocator.get<WebSocketService>();
  final GlobalUserBloc _globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  final SelectedFileInfoList _wrapSelectedFileInfoList =
      SelectedFileInfoList([]);
  bool _isLoadingFile = false;
  bool _friendAcceptedRequest = false;
  final _sendFileBloc = serviceLocator.get<SendFileBloc>();
  bool _isSendingFile = false;
  int? _totalChunks;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _sendFileBloc.friendUid = null;
    _sendFileBloc.fileListHashCode = null;
    super.dispose();
  }

  Future<bool> _sendFile(int fileIndex, String fileName, int fileSize,
      Stream<List<int>> fileData) async {
    _totalChunks = (fileSize / 32768).ceil();

    int counter = 0;
    print(_totalChunks);
    setState(() {
      _isSendingFile = true;
    });
    await for (var data in fileData) {
      // 发送分片
      try {
        print("开始发送文件:$fileName的第$counter个分片, 一共$_totalChunks个分片");
        //data的length 默认为65536,也就是 默认一次发送64KB,这里一次发送32KB,防止出现文件大小大于65536的错误
        if (data.length > 32768) {
          int mid = (data.length / 2).floor();
          var data1 = data.sublist(0, mid);
          print("超过64KB第一部分的大小: ${data1.length}");
          _webSocketService.sendFileSlice(
              fileIndex,
              fileName,
              _globalUserBloc.globalUser!.userId,
              widget.friendUid,
              data1,
              data1.length,
              counter,
              _totalChunks!);
          counter++;
          var data2 = data.sublist(mid);
          print("超过64KB第二部分的大小: ${data2.length}");
          _webSocketService.sendFileSlice(
              fileIndex,
              fileName,
              _globalUserBloc.globalUser!.userId,
              widget.friendUid,
              data2,
              data2.length,
              counter,
              _totalChunks!);
        } else {
          _webSocketService.sendFileSlice(
              fileIndex,
              fileName,
              _globalUserBloc.globalUser!.userId,
              widget.friendUid,
              data,
              data.length,
              counter,
              _totalChunks!);
        }
        counter++;
      } catch (e) {
        print(e);
        return false;
      }
      // 更新进度
      setState(() {
        var progress = counter / _totalChunks!;
        _wrapSelectedFileInfoList.selectedFileInfoList[fileIndex].sendProgress =
            progress;
        print(progress);
      });
    }
    setState(() {
      _isSendingFile = false; // 完成发送
    });
    return true;
  }

  void _startSendFile() async {
    for (int i = 0;
        i < _wrapSelectedFileInfoList.selectedFileInfoList.length;
        i++) {
      print(
          "此次发送的文件数量为:${_wrapSelectedFileInfoList.selectedFileInfoList.length}");
      var file = _wrapSelectedFileInfoList.selectedFileInfoList[i];
      if (file.fileData != null) {
        final result =
            await _sendFile(i, file.fileName, file.fileSize, file.fileData!);
        if (result) {
          file.fileStatus = SendFileStatus.succeed;
        } else {
          file.fileStatus = SendFileStatus.failed;
        }
      } else {
        file.errorMsg = "文件为空,不可发送";
        print("文件为空,不可发送");
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithTitleAndArrow(
        title: "在线发送文件",
        centerTitle: true,
      ),
      body: BlocListener<SendFileBloc, SendFileState>(
        listener: (BuildContext context, state) {
          if (state is FriendHasAcceptedReq) {
            if (_sendFileBloc.friendUid == widget.friendUid) {
              setState(() {
                _friendAcceptedRequest = true;
              });
            }
          }
        },
        child: Column(
          children: [
            const Text("由于文件不会上传到服务器,所以发送文件需要对方在线"),
            const SizedBox(height: 10),
            const Text("对方同意接收文件后将在线发送文件"),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () async {
                    print("点击了选择文件按钮");
                    setState(() {
                      _friendAcceptedRequest = false;
                    });
                    try {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              withReadStream: true,
                              onFileLoading: (status) {
                                if (status == FilePickerStatus.picking) {
                                  setState(() {
                                    _isLoadingFile = true;
                                  });
                                  print("当前正在加载");
                                }
                              });
                      if (result != null) {
                        var files = result.files;
                        print(
                            "添加文件前文件列表的hashCode: ${_wrapSelectedFileInfoList.hashCode}");
                        for (int i =0;i<files.length;i++) {
                          if (files[i].readStream != null) {
                            _wrapSelectedFileInfoList.selectedFileInfoList.add(
                                FileToSend(
                                  fileIndex: i,
                                    fileName: files[i].name,
                                    fileSize: files[i].size,
                                    fileStatus: SendFileStatus.notSendYet,
                                    fileData: files[i].readStream!));
                          } else {
                            print("文件${files[i].name}无法读取,readStream为null");
                          }
                        }
                        setState(() {
                          _isLoadingFile = false;
                        });
                        print("加载完成");
                        print(
                            "添加文件后文件列表的hashCode: ${_wrapSelectedFileInfoList.hashCode}");
                      }
                    } catch (e) {
                      print("文件加载失败,请清空缓存后重试");
                    }
                  },
                  child: const Text('选择文件'),
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () async {
                    print("点击了清除文件缓存");
                    if (PlatformUtils.isMobile) {
                      final result =
                          await FilePicker.platform.clearTemporaryFiles();
                      if (result != null && result) {
                        setState(() {
                          _wrapSelectedFileInfoList.selectedFileInfoList
                              .clear();
                          _friendAcceptedRequest = false;
                        });
                      }
                    } else {
                      setState(() {
                        _wrapSelectedFileInfoList.selectedFileInfoList.clear();
                        _friendAcceptedRequest = false;
                      });
                    }
                  },
                  child: const Text('清除缓存'),
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () async {
                    print(
                        "点击了请求发送文件,发送文件的hashCode: ${_wrapSelectedFileInfoList.hashCode}");
                    if (_wrapSelectedFileInfoList
                        .selectedFileInfoList.isNotEmpty) {
                      _webSocketService.sendFileRequest(
                          widget.friendUid,
                          _globalUserBloc.globalUser!.userId,
                          _wrapSelectedFileInfoList.selectedFileInfoList,
                          _wrapSelectedFileInfoList.hashCode);
                    } else {
                      ShowWidgetUtil.showToast(context, "请选择至少一个文件");
                    }
                  },
                  child: const Text('请求发送文件'),
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () async {
                    print(
                        "点击了开始发送文件,对方收到的文件列表的hashCode: ${_sendFileBloc.fileListHashCode},我方待发送文件列表的hashCode: ${_wrapSelectedFileInfoList.hashCode}");
                    if (!_friendAcceptedRequest) {
                      ShowWidgetUtil.showSnackBar(
                          context, "对方尚未响应你的文件请求,暂时不能发送,请等待对方先响应");
                      return;
                    }
                    if (_sendFileBloc.fileListHashCode !=
                        _wrapSelectedFileInfoList.hashCode) {
                      ShowWidgetUtil.showSnackBar(context,
                          "你与对方的文件校验码不同,可能是因为你修改了文件列表,这会导致文件发送错误,请重新请求发送文件");
                    } else {
                      print(
                          "可以发送文件了,对方收到的文件列表的hashCode: ${_sendFileBloc.fileListHashCode},我方当前待发送文件列表的hashCode: ${_wrapSelectedFileInfoList.hashCode}");
                      _startSendFile();
                    }
                  },
                  child: const Text('开始发送文件'),
                ),
              ],
            ),
            Text("文件校验码:${_wrapSelectedFileInfoList.hashCode},请注意与好友的文件校验码比对"),
            const Text("已选择的文件如下,左滑删除"),
            _friendAcceptedRequest
                ? const Text("好友接受了发送文件申请")
                : const Text("好友尚未响应你的文件申请"),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _isLoadingFile
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Material(
                        child: ListView.builder(
                            itemCount: _wrapSelectedFileInfoList
                                .selectedFileInfoList.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                  endActionPane: ActionPane(
                                      extentRatio: 0.3,
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          fontSize: 16,
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          onPressed: (context) {
                                            print("点击了删除");
                                            _wrapSelectedFileInfoList
                                                .removeAt(index);
                                            if (_wrapSelectedFileInfoList
                                                .isEmpty) {
                                              if (PlatformUtils.isMobile) {
                                                FilePicker.platform
                                                    .clearTemporaryFiles();
                                              }
                                            }
                                          },
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          label: '删除',
                                          flex: 2,
                                        ),
                                      ]),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                              "文件名: ${_wrapSelectedFileInfoList.selectedFileInfoList[index].fileName}"),
                                          subtitle: Text(
                                              "文件大小: ${_wrapSelectedFileInfoList.selectedFileInfoList[index].getFixedFileSize()}"),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 100, // 设置进度条的宽度
                                            child: LinearProgressIndicator(
                                              value: _wrapSelectedFileInfoList
                                                  .selectedFileInfoList[index]
                                                  .sendProgress, // 替换为实际进度值
                                            ),
                                          ),
                                          Text(
                                              "${(_wrapSelectedFileInfoList.selectedFileInfoList[index].sendProgress * 100).toStringAsFixed(2)}%"),
                                          Text(
                                              "文件状态: ${_wrapSelectedFileInfoList.selectedFileInfoList[index].fileStatus.desc}")
                                        ],
                                      ),
                                    ],
                                  ));
                            }),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
