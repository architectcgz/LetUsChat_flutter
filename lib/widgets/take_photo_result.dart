import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import 'package:photo_view/photo_view.dart';

class TakePhotoResultPage extends StatefulWidget {
  final String filePath;
  const TakePhotoResultPage({super.key, required this.filePath});

  @override
  State<TakePhotoResultPage> createState() => _TakePhotoResultPageState();
}

class _TakePhotoResultPageState extends State<TakePhotoResultPage> {
  late final File _oldImage;
  late File _croppedImage;
  @override
  void initState() {
    super.initState();
    _oldImage = File(widget.filePath);
    _croppedImage = _oldImage;
    _cropImageAndSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithTitleAndArrow(),
      body: Stack(
        children: [
          PhotoView(
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              imageProvider: FileImage(_croppedImage)),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      print("点击了确定按钮");
                      GoRouter.of(context).pop(_croppedImage);
                    },
                    child: const Text("确定"))
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _cropImageAndSet() async {
    _croppedImage = (await _cropImage(imageFile: _oldImage)) ?? _oldImage;
    setState(() {});
  }

  Future<File?> _cropImage({required File imageFile}) async {
    try {
      CroppedFile? croppedImg = await ImageCropper()
          .cropImage(sourcePath: imageFile.path, compressQuality: 100);

      if (croppedImg == null) {
        return null;
      } else {
        return File(croppedImg.path);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
