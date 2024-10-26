import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:let_us_chat/blocs/authentication/authentication_bloc.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/utils/shared_preference_utils.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/pages/utils/platform_utils.dart';
import 'package:let_us_chat/repository/models/friend.dart';
import 'package:let_us_chat/repository/models/group_message.dart';
import 'package:let_us_chat/repository/models/private_message.dart';
import 'package:let_us_chat/repository/models/recent_chat.dart';
import 'package:let_us_chat/repository/models/request_friend_info.dart';
import 'package:let_us_chat/routes/app_navigation.dart';
import 'package:let_us_chat/styles/app_themes.dart';
import 'package:path_provider/path_provider.dart';

import 'blocs/theme_bloc/theme_bloc.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(FriendAdapter());
  Hive.registerAdapter(RequestFriendInfoAdapter());
  Hive.registerAdapter(RecentChatAdapter());
  Hive.registerAdapter(PrivateMessageAdapter());
  Hive.registerAdapter(GroupMessageAdapter());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Bloc.observer = AppBlocObserver();
  await initHive();
  await setUpServiceLocator();
  var tempDir = await getApplicationDocumentsDirectory();
  var fileTempDir = '${tempDir.path}/tempFile';
  print(fileTempDir);

  // await SharedPreferenceUtil.deleteKeyboardHeight();
  if (!PlatformUtils.isMobile) {
    globalKeyboardHeight = 325;
  } else {
    globalKeyboardHeight = await SharedPreferenceUtil.getKeyboardHeight();
  }
  print("键盘高度: $globalKeyboardHeight");
  print("当前项目文件夹为: ${await getApplicationDocumentsDirectory()}");
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator.get<ThemeBloc>(), // 加载主题
          ),
          BlocProvider(
            create: (context) =>
                AuthenticationBloc()..add(AppStarted()), // 加载登录状态
          ),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final webSocketService = serviceLocator.get<WebSocketService>();

  @override
  void dispose() {
    serviceLocator.reset();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          print("已登录");
          AppNavigation.router.go("/chatList");
          webSocketService.startConnection();
        } else if (state is UnAuthenticated) {
          print("未登录");
          webSocketService.disconnect();
          if (!state.isFirstLogin) {
            resetBlocsOnLogout();
          }
          AppNavigation.router.go("/auth");
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, authState) {
              return MaterialApp.router(
                themeMode: ThemeMode.system,
                theme: themeState.themeData, // 动态主题
                darkTheme: AppThemes.darkTheme,
                routerConfig: AppNavigation.router,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', ''), // English
                  Locale('zh', ''), // 中文
                ],
                locale: const Locale('zh'),
              );
            },
          );
        },
      ),
    );
  }
}
