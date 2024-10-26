import 'dart:io';

import 'package:dio/dio.dart';
import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

class FileService {
  final DioClient _dioClient = serviceLocator.get<DioClient>();

  Future<String?> uploadAvatar(File file) async {
    FormData formData =
        FormData.fromMap({"file": await MultipartFile.fromFile(file.path)});
    final result =
        await _dioClient.dio.post("/file/avatar/upload", data: formData);
    if (result.data['code'] == 200) {
      return result.data['data'];
    }
    return null;
  }

  Future<String?> uploadImage(File image) async {
    FormData formData =
        FormData.fromMap({"image": await MultipartFile.fromFile(image.path)});
    final result =
        await _dioClient.dio.post("/file/image/upload", data: formData);
    if (result.data['code'] == 200) {
      print("图片上传后得到的url为: ${result.data['data']}");
      return result.data['data'];
    }
    return null;
  }

  Future<String?> uploadVoice(File voice) async {
    print(await voice.length());
    var data = await MultipartFile.fromFile(voice.path);
    print("语音的大小为: ${data.length}");

    var formData =
        FormData.fromMap({'voice': await MultipartFile.fromFile(voice.path)});
    final result = await _dioClient.dio.post("/file/voice/upload",
        data: formData, options: Options(contentType: 'multipart/form-data'));
    print(result);
    if (result.data['code'] == 200) {
      return result.data['data'];
    }
    return null;
  }

  Future<String?> uploadFile(File file) async {
    FormData formData =
        FormData.fromMap({"file": await MultipartFile.fromFile(file.path)});
    final result = await _dioClient.dio.post("/file/upload", data: formData);
    if (result.data['code'] == 200) {
      return result.data['data'];
    }
    return null;
  }
}
