import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/services/friend_service.dart';
import 'package:let_us_chat/core/services/user_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/utils/shared_preference_utils.dart';
import 'package:let_us_chat/repository/local/local_friend_repo.dart';
import 'package:let_us_chat/repository/local/local_friend_request_repo.dart';
import 'package:let_us_chat/repository/local/set_up_box_repo.dart';
import '../../core/errors/exception.dart';
import '../../models/user.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  final userService = serviceLocator.get<UserService>();
  final friendService = serviceLocator.get<FriendService>();
  final dioClient = serviceLocator.get<DioClient>();
  LoginBloc() : super(LoginInitial()) {
    on<LoginRequestEvent>((event,emit) async {
      emit(Logging());
      Map<String, dynamic>? result;
      try{
        if(event.loginType==0){
          try{
            result = await userService.loginByEmail(event.username, event.password);
          }on CustomException
          catch(e){
            emit(EmailLoginFailed(code: e.code, message: e.message));
          }
        }
        else{
          try{
            result = await userService.loginByPhone(event.username, event.password);
          }on CustomException
          catch(e){
            emit(PhoneLoginFailed(code: e.code, message: e.message));
          }
        }
        if(result!=null){
          //将accessToken和refreshToken保存到本地
          currentUserId = result["data"]["userId"];
          globalAccessToken = result["data"]["accessToken"];

          await dioClient.saveAccessToken(result["data"]["accessToken"]);
          await dioClient.saveRefreshToken(result["data"]["refreshToken"]);
          print("运行到此");
          await setUpBoxAndRepo(currentUserId!);
          print("自此未出现问题");
          await SharedPreferenceUtil.setUserLoggedIn();
          await SharedPreferenceUtil.saveCurrentUserId(currentUserId!);
          if(event.loginType==0){
            emit(EmailLoginSucceed());
          }else{
            emit(PhoneLoginSucceed());
          }
        }else{
          if(event.loginType==0){
            emit(EmailLoginFailed(code: 400, message: ""));
          }else{
            emit(PhoneLoginFailed(code: 400, message: ""));
          }
        }

      }on CustomException
      catch(e){
        if(event.loginType==0){
          emit(EmailLoginFailed(code: e.code, message: e.message));
        }else{
          emit(PhoneLoginFailed(code: e.code, message: e.message));
        }

      }
    });
    on<LoginSucceedEvent>((event,emit)async{
      User? user;
      try{
        print("获取用户信息...");
        user = await userService.getUserInfo();
        print("用户信息: ${user.toString()}");
        //用户信息保存到本地
        if(user!=null){
          globalUserBloc.add(SaveGlobalUserInfoEvent(user: user));
          emit(GetUserInfoSucceed());
        }else{
          emit(GetNecessaryInfoFailed(code: 404, message: "获取用户信息失败"));
        }
      }on CustomException
      catch(e){
        emit(GetNecessaryInfoFailed(code: e.code, message: e.message));
      }
      if(user!=null){
        try{
          //获取请求列表
          print("获取请求列表");
          final requestList = await friendService.getRequestFriendList();
          print("好友请求数量: ${requestList?.length}");
          if(requestList!=null){
            await serviceLocator.get<LocalFriendRequestRepo>().saveRequestListData(requestList);
          }
          //获取好友列表
          print("获取好友列表");
          final friendList = await friendService.getFriendList();
          print("好友数量: ${friendList?.length}");
          //将好友列表信息保存到本地
          if (friendList != null) {
            await serviceLocator.get<LocalFriendRepo>().saveFriends(friendList);
            for (var friend in friendList) {
              print(friend.toString());
            }
          }
        }on CustomException
        catch(e){
          throw CustomException(code: e.code, message: e.message);
        }
      }

    });
  }
}
