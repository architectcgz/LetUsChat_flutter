import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/services/user_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

part 'qr_code_event.dart';
part 'qr_code_state.dart';

class QrCodeBloc extends Bloc<QrCodeEvent, QrCodeState> {
  final userService = serviceLocator.get<UserService>();
  final globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  QrCodeBloc() : super(QrCodeInitial()) {
    on<QrCodeEvent>((event, emit) {
      print("QRcode event 还没完成!!");
    });
    on<FetchQRCode>((event, emit) async {
      try {
        var result = globalUserBloc.globalUser!.qrCode;
        emit(QrCodeLoaded(base64Decode(result)));
      } on CustomException catch (e) {
        emit(QrCodeError("用户二维码获取失败,请稍后重试:${e.message}"));
      }
    });
  }
}
