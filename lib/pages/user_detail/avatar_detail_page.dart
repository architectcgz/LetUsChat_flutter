import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import '../../blocs/global_user/global_user_bloc.dart';
import '../../core/utils/injection_container.dart';
import '../utils/image_picker_util.dart';

class AvatarDetailPage extends StatefulWidget {
  const AvatarDetailPage({super.key});

  @override
  State<AvatarDetailPage> createState() => _AvatarDetailPageState();
}

class _AvatarDetailPageState extends State<AvatarDetailPage> {
  dynamic _image;
  final picker = ImagePicker();
  final globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalUserBloc, GlobalUserState>(
      listener: (context, state) {
        if (state is UploadAvatarFailed) {
          ShowWidgetUtil.showSnackBar(context, "头像上传失败: ${state.message}");
        } else if (state is UploadAvatarSucceed) {
          // 显示成功消息
          ShowWidgetUtil.showSnackBar(context, '头像上传成功!');
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: const Text("头像"),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'gallery':
                        _showOptions().then((image) {
                          if (image != null) {
                            setState(() {
                              _image = image;
                            });
                            globalUserBloc.add(UploadAvatarEvent(file: image));
                          }
                        });
                        break;
                      case 'save':
                        break;
                      case 'camera':
                        ImagePickerUtil.getImageFromCamera(picker).then((file) {
                          if (file != null) {
                            setState(() {
                              _image = file;
                            });
                            globalUserBloc.add(UploadAvatarEvent(file: file));
                          }
                        });
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'gallery',
                        child: Text('从手机相册选择'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'save',
                        child: Text('保存到手机'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'camera',
                        child: Text('拍摄照片'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            backgroundColor: Colors.black, // 背景颜色设置为黑色
            body: Center(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.black, // 图片外部的背景为黑色
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : Image.network(
                            globalUserBloc.globalUser!.avatar,
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (state is UploadingAvatar)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      color: Colors.black.withOpacity(
                          0.5), // Optional semi-transparent overlay
                      child: const Center(
                        child: CircularProgressIndicator(), // 显示加载状态
                      ),
                    ),
                ],
              ),
            ));
      },
    );
  }

  Future<File?> _showOptions() async {
    return await showCupertinoModalPopup<File?>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('相册'),
            onPressed: () async {
              Navigator.of(context)
                  .pop(await ImagePickerUtil.getImageFromGallery(picker));
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('照相机'),
            onPressed: () async {
              Navigator.of(context)
                  .pop(await ImagePickerUtil.getImageFromCamera(picker));
            },
          ),
        ],
      ),
    );
  }
}
