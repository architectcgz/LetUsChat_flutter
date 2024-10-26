import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/services/file_service.dart';
import 'package:let_us_chat/core/services/user_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:meta/meta.dart';

import '../../core/errors/exception.dart';
import '../../core/utils/secure_storage_util.dart';
import '../../models/user.dart';

part 'global_user_event.dart';
part 'global_user_state.dart';

class GlobalUserBloc extends Bloc<GlobalUserEvent, GlobalUserState> {
  User? globalUser;
  final fileService = serviceLocator.get<FileService>();
  final userService = serviceLocator.get<UserService>();
  GlobalUserBloc() : super(GlobalUserInitial()) {
    on<LoadGlobalUserInfoEvent>((event, emit) async {
      globalUser = await SecureStorageUtil.getUserInfo(currentUserId!);
    });
    on<UpdateGlobalUserInfoEvent>((event, emit) async {
      globalUser = event.newUser;
      await SecureStorageUtil.saveUserInfo(globalUser!);
    });
    on<SaveGlobalUserInfoEvent>((event, emit) async {
      globalUser = event.user;
      currentUserId = globalUser!.userId;
      await SecureStorageUtil.saveUserInfo(event.user);
      final result = await SecureStorageUtil.getUserInfo(currentUserId!);
      print("保持后获取到的信息$result ");
    });
    on<UploadAvatarEvent>((event, emit) async {
      print("上传头像文件");
      emit(UploadingAvatar());
      final result = await fileService.uploadAvatar(event.file);
      if (result != null) {
        //修改用户信息
        var temp = globalUser;
        try {
          print("oldAvatar: ${temp!.avatar}");
          temp.avatar = result;
          await userService.updateUserInfo(temp); //如果出错不会执行下去
          final newQRCode = await userService.getQRCode();
          if (newQRCode != null) {
            print("新的qrCode");
            globalUser!.qrCode = newQRCode;
          }
          add(UpdateGlobalUserInfoEvent(newUser: temp));
          emit(UploadAvatarSucceed());
        } on CustomException catch (e) {
          emit(UploadAvatarFailed(message: e.message));
        }
      } else {
        emit(UploadAvatarFailed(message: "头像上传失败,请稍后再试"));
      }
    });
    on<UpdateSignatureEvent>((event, emit) async {
      String signature = event.newSignature;
      if (signature.length > 20) {
        emit(SignatureExceedLength());
      } else {
        var temp = globalUser;
        try {
          temp!.signature = signature;
          await userService.updateUserInfo(temp);
          add(UpdateGlobalUserInfoEvent(newUser: temp));
          emit(UpdateSignatureSucceed());
        } on CustomException catch (e) {
          emit(UpdateSignatureFailed(message: e.message));
        }
      }
    });
    on<UpdateUsernameEvent>((event, emit) async {
      String username = event.username;
      if (username.length > 10) {
        emit(UsernameExceedLength());
      } else {
        var temp = globalUser;
        try {
          temp!.username = username;
          await userService.updateUserInfo(temp);
          add(UpdateGlobalUserInfoEvent(newUser: temp));
          emit(UpdateUsernameSucceed());
        } on CustomException catch (e) {
          emit(UpdateUsernameFailed(message: e.message));
        }
      }
    });
    on<UpdateLocationEvent>((event, emit) async {
      var temp = globalUser;
      temp!.location = event.newLocation;
      try {
        await userService.updateUserInfo(temp);
        add(UpdateGlobalUserInfoEvent(newUser: temp));
        emit(UpdateLocationSucceed());
      } on CustomException catch (e) {
        emit(UpdateLocationFailed(message: e.message));
      }
    });
    on<UpdateGenderEvent>((event, emit) async {
      var temp = globalUser;
      temp!.gender = event.newGender;
      try {
        await userService.updateUserInfo(temp);
        add(UpdateGlobalUserInfoEvent(newUser: temp));
        emit(UpdateGenderSucceed());
      } on CustomException catch (e) {
        emit(UpdateGenderFailed(message: e.message));
      }
    });
  }
}
