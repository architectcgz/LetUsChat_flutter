import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:let_us_chat/blocs/add_friend_group/add_friend_group_bloc.dart';
import 'package:let_us_chat/blocs/authentication/authentication_bloc.dart';
import 'package:let_us_chat/blocs/chat/group_chat/group_chat_bloc.dart';
import 'package:let_us_chat/blocs/chat/single_chat/single_chat_bloc.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/blocs/find/find_bloc.dart';
import 'package:let_us_chat/blocs/friend_info/friend_info_bloc.dart';
import 'package:let_us_chat/blocs/friend_request_list/friend_request_list_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/blocs/login/login_bloc.dart';
import 'package:let_us_chat/blocs/navbar_bloc/navbar_bloc.dart';
import 'package:let_us_chat/blocs/receive_file/bloc/receive_file_bloc.dart';
import 'package:let_us_chat/blocs/request_friend_info/request_friend_info_bloc.dart';
import 'package:let_us_chat/blocs/register/register_bloc.dart';
import 'package:let_us_chat/blocs/send_file/send_file_bloc.dart';
import 'package:let_us_chat/blocs/setting/settings_bloc.dart';
import 'package:let_us_chat/blocs/theme_bloc/theme_bloc.dart';
import 'package:let_us_chat/core/constants/constants.dart';

import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/services/captcha_service.dart';
import 'package:let_us_chat/core/services/file_service.dart';
import 'package:let_us_chat/core/services/friend_service.dart';
import 'package:let_us_chat/core/services/group_msg_service.dart';
import 'package:let_us_chat/core/services/group_service.dart';
import 'package:let_us_chat/core/services/private_msg_service.dart';
import 'package:let_us_chat/core/services/user_service.dart';
import 'package:let_us_chat/repository/local/set_up_box_repo.dart';

import '../../blocs/qr_code_bloc/qr_code_bloc.dart';
import '../websocket/websocket_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setUpServiceLocator() async {
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerSingleton<DioClient>(DioClient());

  serviceLocator.registerSingleton<FriendService>(FriendService());
  serviceLocator.registerSingleton<CaptchaService>(CaptchaService());
  serviceLocator.registerSingleton<GroupService>(GroupService());
  serviceLocator.registerSingleton<UserService>(UserService());
  serviceLocator.registerSingleton<FileService>(FileService());
  serviceLocator.registerSingleton<WebSocketService>(
      WebSocketService(serverUrl: wsServerBaseUrl));
  serviceLocator
      .registerSingleton<PrivateMessageService>(PrivateMessageService());
  serviceLocator.registerSingleton<GroupMessageService>(GroupMessageService());

  serviceLocator.registerLazySingleton(() => AuthenticationBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<NavbarBloc>(() => NavbarBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<ThemeBloc>(() => ThemeBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<GlobalUserBloc>(() => GlobalUserBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<RegisterBloc>(() => RegisterBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<LoginBloc>(() => LoginBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<RecentChatListBloc>(
      () => RecentChatListBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<ContactListBloc>(() => ContactListBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<FindBloc>(() => FindBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<SettingsBloc>(() => SettingsBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerFactory<FriendInfoBloc>(() => FriendInfoBloc());
  serviceLocator.registerLazySingleton<QrCodeBloc>(() => QrCodeBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<AddFriendGroupBloc>(
      () => AddFriendGroupBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<FriendRequestListBloc>(
      () => FriendRequestListBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator
      .registerFactory<RequestFriendInfoBloc>(() => RequestFriendInfoBloc());
  serviceLocator.registerLazySingleton<SendFileBloc>(() => SendFileBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<ReceiveFileBloc>(() => ReceiveFileBloc(),
      dispose: (bloc) => bloc.close());
}

void resetBlocsOnLogout() {
  // 关闭 Bloc
  serviceLocator<NavbarBloc>().close();
  serviceLocator<GlobalUserBloc>().close();
  serviceLocator<RegisterBloc>().close();
  serviceLocator<LoginBloc>().close();
  serviceLocator<RecentChatListBloc>().close();
  serviceLocator<ContactListBloc>().close();
  serviceLocator<FindBloc>().close();
  serviceLocator<SettingsBloc>().close();
  serviceLocator<FriendInfoBloc>().close();
  serviceLocator<QrCodeBloc>().close();
  serviceLocator<AddFriendGroupBloc>().close();
  serviceLocator<FriendRequestListBloc>().close();
  serviceLocator<RequestFriendInfoBloc>().close();
  serviceLocator<SingleChatBloc>().close();
  serviceLocator<GroupChatBloc>().close();
  serviceLocator<SendFileBloc>().close();
  serviceLocator<ReceiveFileBloc>().close;
  // 注销现有的 Bloc 实例
  unRegisterRepoBlocs();
  serviceLocator.unregister<NavbarBloc>();
  serviceLocator.unregister<GlobalUserBloc>();
  serviceLocator.unregister<RegisterBloc>();
  serviceLocator.unregister<LoginBloc>();
  serviceLocator.unregister<RecentChatListBloc>();
  serviceLocator.unregister<ContactListBloc>();
  serviceLocator.unregister<FindBloc>();
  serviceLocator.unregister<SettingsBloc>();
  serviceLocator.unregister<FriendInfoBloc>();
  serviceLocator.unregister<QrCodeBloc>();
  serviceLocator.unregister<AddFriendGroupBloc>();
  serviceLocator.unregister<FriendRequestListBloc>();
  serviceLocator.unregister<RequestFriendInfoBloc>();
  serviceLocator.unregister<SingleChatBloc>();
  serviceLocator.unregister<GroupChatBloc>();
  serviceLocator.unregister<SendFileBloc>();
  serviceLocator.unregister<ReceiveFileBloc>();
  // 重新注册这些 Bloc 实例
  serviceLocator.registerLazySingleton<NavbarBloc>(() => NavbarBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<GlobalUserBloc>(() => GlobalUserBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<RegisterBloc>(() => RegisterBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<LoginBloc>(() => LoginBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<RecentChatListBloc>(
      () => RecentChatListBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<ContactListBloc>(() => ContactListBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<FindBloc>(() => FindBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<SettingsBloc>(() => SettingsBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerFactory<FriendInfoBloc>(() => FriendInfoBloc());
  serviceLocator.registerLazySingleton<QrCodeBloc>(() => QrCodeBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<AddFriendGroupBloc>(
      () => AddFriendGroupBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<FriendRequestListBloc>(
      () => FriendRequestListBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator
      .registerFactory<RequestFriendInfoBloc>(() => RequestFriendInfoBloc());
  serviceLocator.registerFactory<SingleChatBloc>(() => SingleChatBloc());
  serviceLocator.registerFactory<GroupChatBloc>(() => GroupChatBloc());
  serviceLocator.registerLazySingleton<SendFileBloc>(() => SendFileBloc(),
      dispose: (bloc) => bloc.close());
  serviceLocator.registerLazySingleton<ReceiveFileBloc>(() => ReceiveFileBloc(),
      dispose: (bloc) => bloc.close());
}
