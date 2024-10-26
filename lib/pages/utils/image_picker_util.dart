import 'dart:io';

import 'package:image_picker/image_picker.dart';


class ImagePickerUtil{
  static Future<File?> getImageFromGallery(ImagePicker picker) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print("No file was picked from gallery");
      return null;
    }
  }

  static Future<List<XFile>?> getMultipleImageFromGallery(ImagePicker picker,int? limit)async{
    return await picker.pickMultiImage(limit: limit);
  }

  static Future<File?> getImageFromCamera(ImagePicker picker) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print("No file was picked from camera");
      return null;
    }
  }
}