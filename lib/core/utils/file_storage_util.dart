import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'injection_container.dart';

class FileStorageUtil{

  static Future<String> saveFile(String fileName, File file) async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final Directory filesDir = Directory('${documentDir.path}/files');
    // 检查 files 文件夹是否存在，不存在则创建
    if (!await filesDir.exists()) {
      await filesDir.create(recursive: true);
    }
    final String filePath = "${filesDir.path}/$fileName";
    await file.copy(filePath);
    return filePath;
  }

  // 下载并保存图片到本地
  static Future<bool> saveNetworkImageToGallery(String imageUrl) async {
    Permission imagePermission;
    if(Platform.isAndroid){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if(androidInfo.version.sdkInt<=32){
        imagePermission = Permission.storage;
      }else{
        imagePermission = Permission.photos;
      }
    }else{
      imagePermission = Permission.storage;
    }

    final granted = await imagePermission.status.isGranted;
    if(!granted){
      await imagePermission.request();
    }
    final Dio dio = serviceLocator.get<Dio>();
    var response = await dio.get(imageUrl,options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),quality: 100,name: "image_${DateTime.timestamp()}") as Map<dynamic,dynamic>;
    return result['isSuccess'];
  }
  static Future<String> saveImage(String fileName, File image) async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${documentDir.path}/images');

    // 检查 images 文件夹是否存在，不存在则创建
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String filePath = "${imagesDir.path}/$fileName";
    await image.copy(filePath);
    return filePath;
  }

  static Future<void> clearImages() async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${documentDir.path}/images');

    // 检查 images 文件夹是否存在
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true); // 删除整个文件夹及其内容
    }
  }

  static Future<void> deleteFile(String fileName) async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final Directory filesDir = Directory('${documentDir.path}/files');
    final File file = File('${filesDir.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

}