import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/utils/secure_storage_util.dart';
import 'package:let_us_chat/core/utils/shared_preference_utils.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import '../../repository/local/set_up_box_repo.dart';
import '../../routes/app_navigation.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

/// 验证用户登录状态的bloc
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  GlobalUserBloc globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<AppStarted>((event, emit) async {
      currentUserId = await SharedPreferenceUtil.getCurrentUserId();
      globalAccessToken = currentUserId != null
          ? await SecureStorageUtil.getAccessToken(currentUserId!)
          : null;
      AppNavigation.isLoggedIn = await SharedPreferenceUtil.isUserLoggedIn();

      if (currentUserId != null && AppNavigation.isLoggedIn) {
        globalUserBloc.globalUser =
            await SecureStorageUtil.getUserInfo(currentUserId!);
        print(
            "globalUserBloc.globalUser==null?: ${globalUserBloc.globalUser == null}");
        if (globalUserBloc.globalUser != null) {
          await setUpBoxAndRepo(currentUserId!);
          emit(Authenticated());
        } else {
          emit(UnAuthenticated(isFirstLogin: true));
        }
      } else {
        emit(UnAuthenticated(isFirstLogin: true));
      }
    });

    on<LoggedOut>((event, emit) async {
      await SharedPreferenceUtil.setUserLoggedOut();
      final result = await SharedPreferenceUtil.isUserLoggedIn();
      print("用户是否仍在登录: $result");
      serviceLocator.get<WebSocketService>().disconnect();
      emit(UnAuthenticated(isFirstLogin: false));
    });
    on<LoggedIn>((event, emit) async {
      serviceLocator.get<WebSocketService>().startConnection();
      emit(Authenticated());
    });
  }
}
