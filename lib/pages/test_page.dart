import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:let_us_chat/blocs/receive_file/bloc/receive_file_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<StatefulWidget> createState() => _TextPageState();
}

class _TextPageState extends State<TestPage> {
  late final TextEditingController _textEditingController;
  late final ReceiveFileBloc _receiveFileBloc;
  late String _filePath;
  @override
  void initState() {
    _filePath = "尚未查询";
    _textEditingController = TextEditingController();
    _receiveFileBloc = serviceLocator.get<ReceiveFileBloc>();
    _textEditingController.addListener((){
      // if(_textEditingController.text.isNotEmpty){
      //   _textEditingController.clear();
      // }
    });
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWithTitleAndArrow(
          title: "测试界面",
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("1.测试接收文件名重复时的处理"),
                  TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: "请输入查询的文件名",
                      border: InputBorder.none,
                    ),
                  ),
                  Text("查询结果: $_filePath"),
                  TextButton(
                      onPressed: () async {
                        _filePath = await _receiveFileBloc.getTempFilePath("U58714596838", _textEditingController.text);
                        print("返回的文件路径为: $_filePath");
                        setState(() {

                        });
                      }, child: const Text("点击查看文件是否重复")),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("2.测试..."),
                  TextField(
                    controller: _textEditingController,
                  ),
                  TextButton(
                      onPressed: () async {}, child: const Text("点击查看文件是否重复")),
                ],
              ),
            ),
          ],
        ),);
  }
}
