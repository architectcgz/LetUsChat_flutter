import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:let_us_chat/core/utils/file_storage_util.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_more.dart';
import 'package:photo_view/photo_view.dart';


class ChatPhotoView extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;

  const ChatPhotoView({super.key, this.imagePath, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWithMore(
          onPressed: () {
            print("点击了更多");
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Center(
                          child: Text("保存"),
                        ),
                        onTap: () async{
                          print("点击了保存");
                          if(imageUrl!=null){
                            final result = await FileStorageUtil.saveNetworkImageToGallery(imageUrl!);
                            if(result){
                              if(context.mounted){
                                Navigator.pop(context);
                                ShowWidgetUtil.showToast(context, "图片下载成功");
                              }
                            }else{
                              if(context.mounted){
                                Navigator.pop(context);
                                ShowWidgetUtil.showToast(context, "图片下载失败");
                              }
                            }

                          }
                        },
                      ),
                      const Divider(
                        thickness: 0.8,
                        color: Colors.grey,
                      ),
                      ListTile(
                        title: const Center(
                          child: Text("分享"),
                        ),
                        onTap: () {
                          print("点击了分享");
                        },
                      ),
                    ],
                  );
                });
          },
        ),
        body: PhotoView(
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          imageProvider: imageUrl != null
              ? CachedNetworkImageProvider(imageUrl!)
          as ImageProvider // 使用 CachedNetworkImageProvider
              : FileImage(File(imagePath!)),
        )

      // 使用本地图片
    );
  }

}
