import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/add_friend_group/add_friend_group_bloc.dart';
import 'package:let_us_chat/blocs/chat/group_chat/group_chat_bloc.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/blocs/find/find_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/blocs/login/login_bloc.dart';
import 'package:let_us_chat/blocs/navbar_bloc/navbar_bloc.dart';
import 'package:let_us_chat/blocs/qr_code_bloc/qr_code_bloc.dart';
import 'package:let_us_chat/blocs/receive_file/bloc/receive_file_bloc.dart';
import 'package:let_us_chat/blocs/request_friend_info/request_friend_info_bloc.dart';
import 'package:let_us_chat/blocs/send_file/send_file_bloc.dart';
import 'package:let_us_chat/blocs/setting/settings_bloc.dart';
import 'package:let_us_chat/pages/add/add_friend_group_page.dart';
import 'package:let_us_chat/pages/add/add_friend_page.dart';
import 'package:let_us_chat/pages/add/friend_result_page.dart';
import 'package:let_us_chat/pages/auth/auth_page.dart';
import 'package:let_us_chat/pages/change_theme_page.dart';
import 'package:let_us_chat/pages/chat/group_chat_page.dart';
import 'package:let_us_chat/pages/chat/single_chat_info_page.dart';
import 'package:let_us_chat/pages/contact/accept_request_page.dart';
import 'package:let_us_chat/pages/contact/request_friend_info_page.dart';
import 'package:let_us_chat/pages/friend_info/friend_settings_page.dart';
import 'package:let_us_chat/pages/friend_info/update_alias_page.dart';
import 'package:let_us_chat/pages/receive_file_page.dart';
import 'package:let_us_chat/pages/register/email_register_page.dart';
import 'package:let_us_chat/pages/add/search_result_page.dart';
import 'package:let_us_chat/pages/send_file_page.dart';
import 'package:let_us_chat/pages/test_page.dart';
import 'package:let_us_chat/pages/unimplemented_page.dart';
import 'package:let_us_chat/pages/user_detail/avatar_detail_page.dart';
import 'package:let_us_chat/pages/user_detail/location_selection_page.dart';
import 'package:let_us_chat/pages/user_detail/signature_page.dart';
import 'package:let_us_chat/widgets/bottom_navigation_bar.dart';
import 'package:let_us_chat/widgets/custom_photo_gallery.dart';
import 'package:let_us_chat/widgets/chat_photo_view.dart';
import 'package:let_us_chat/widgets/take_photo_result.dart';
import 'package:path/path.dart';
import '../blocs/chat/single_chat/single_chat_bloc.dart';
import '../blocs/friend_info/friend_info_bloc.dart';
import '../blocs/friend_request_list/friend_request_list_bloc.dart';
import '../blocs/register/register_bloc.dart';
import '../core/utils/injection_container.dart';
import '../data/search_result_data.dart';
import '../pages/chat/chat_list_page.dart';
import '../pages/chat/single_chat_page.dart';
import '../pages/contact/contact_list_page.dart';
import '../pages/contact/friend_request_list_page.dart';
import '../pages/find.dart';
import '../pages/friend_info/friend_info_page.dart';
import '../pages/me_and_settings.dart';
import '../pages/register/phone_register_page.dart';
import '../pages/settings.dart';
import '../pages/user_detail/qr_code_page.dart';
import '../pages/user_detail/username_page.dart';
import '../pages/user_detail/user_detail_page.dart';
import '../pages/user_detail/user_more_info_page.dart';
import '../repository/models/friend.dart';

class AppNavigation {
  static bool isLoggedIn = false;
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _userDetailNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'userDetail');
  static GoRouter router = GoRouter(
    initialLocation: isLoggedIn ? '/chatList' : '/auth',
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    // redirect: (context, state) {
    //   // 如果用户已登录，并且当前路径不是 /chatList，则跳转到 /chatList
    //   if (isLoggedIn && state.uri.toString() != '/chatList') {
    //     return '/chatList';
    //   }
    //
    //   // 如果用户未登录，并且当前路径不是 /auth，则跳转到 /auth
    //   if (!isLoggedIn && state.uri.toString() != '/auth') {
    //     return '/auth';
    //   }
    //
    //   // 否则不做跳转
    //   return null;
    // },
    routes: [
      GoRoute(
        path: "/auth",
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator.get<LoginBloc>(),
          child: AuthPage(),
        ),
      ),
      GoRoute(
        path: "/phoneRegister",
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator.get<RegisterBloc>(),
          child: const PhoneRegisterPage(),
        ),
      ),
      GoRoute(
        path: "/emailRegister",
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator.get<RegisterBloc>(),
          child: const EmailRegisterPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocProvider.value(
            value: serviceLocator.get<NavbarBloc>(),
            child: CustomBottomNavigationBar(navigationShell: navigationShell),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/chatList',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: BlocProvider.value(
                    value: serviceLocator.get<RecentChatListBloc>(),
                    child: const ChatListPage(),
                  ),
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              )
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contactList',
                name: 'contactList',
                builder: (context, state) => BlocProvider.value(
                  value: serviceLocator.get<ContactListBloc>(),
                  child: const ContactListPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/find',
                builder: (context, state) => BlocProvider.value(
                      value: serviceLocator.get<FindBloc>(),
                      child: const Find(),
                    )),
          ]),
          StatefulShellBranch(
            navigatorKey: _userDetailNavigatorKey,
            routes: [
              GoRoute(
                path: '/me',
                builder: (context, state) => BlocProvider.value(
                  value: serviceLocator.get<GlobalUserBloc>(),
                  child: const MeAndSettings(),
                ),
              )
            ],
          ),
        ],
      ),
      GoRoute(
          path: "/userDetail",
          name: "userDetail",
          builder: (context, state) => BlocProvider.value(
                value: serviceLocator.get<GlobalUserBloc>(),
                child: const UserDetailPage(),
              ),
          routes: [
            GoRoute(
              path: 'avatarDetail',
              name: 'avatarDetail',
              builder: (context, state) => BlocProvider.value(
                value: serviceLocator.get<GlobalUserBloc>(),
                child: const AvatarDetailPage(),
              ),
            ),
            GoRoute(
              path: 'setUsername',
              name: 'setUsername',
              builder: (context, state) => BlocProvider.value(
                value: serviceLocator.get<GlobalUserBloc>(),
                child: const SetUsernamePage(),
              ),
            ),
            GoRoute(
              path: 'qrCode',
              name: 'qrCode',
              builder: (context, state) => BlocProvider.value(
                value: serviceLocator.get<QrCodeBloc>(),
                child: QrCodePage(),
              ),
            ),
            GoRoute(
              path: 'userMoreInfo',
              name: 'userMoreInfo',
              builder: (context, state) => BlocProvider.value(
                value: serviceLocator.get<GlobalUserBloc>(),
                child: const UserMoreInfoPage(),
              ),
              routes: [
                GoRoute(
                  path: 'locationSelection',
                  name: 'locationSelection',
                  builder: (context, state) => const LocationSelectionPage(),
                ),
                GoRoute(
                  path: 'signature',
                  name: 'signature',
                  builder: (context, state) => BlocProvider.value(
                    value: serviceLocator.get<GlobalUserBloc>(),
                    child: const SignaturePage(),
                  ),
                )
              ],
            ),
          ]),
      GoRoute(
        path: "/addFriendGroup",
        name: "addFriendGroup",
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator.get<AddFriendGroupBloc>(),
          child: const AddFriendGroupPage(),
        ),
        routes: [
          GoRoute(
            path: "searchResult",
            name: "searchResult",
            builder: (context, state) {
              final searchData = state.extra as SearchResultData?;

              return SearchResultsPage(
                friends: searchData?.friends ?? [],
                groups: searchData?.groups ?? [],
              );
            },
            routes: [
              GoRoute(
                  path: "friendResult",
                  name: "friendResult",
                  builder: (context, state) {
                    final friend = state.extra as Friend;
                    return BlocProvider.value(
                      value: serviceLocator.get<AddFriendGroupBloc>(),
                      child: FriendResultPage(friend: friend),
                    );
                  },
                  routes: [
                    GoRoute(
                        path: "addFriend",
                        name: "addFriend",
                        builder: (context, state) {
                          final friend = state.extra as Friend;
                          return BlocProvider.value(
                            value: serviceLocator.get<AddFriendGroupBloc>(),
                            child: AddFriendPage(
                              friend: friend,
                            ),
                          );
                        })
                  ]),
            ],
          ),
        ],
      ),
      GoRoute(
          path: "/unimplementedPage",
          name: 'unimplementedPage',
          builder: (context, state) {
            return const UnImplementedPage();
          }),
      GoRoute(
          path: "/changeThemePage",
          name: "changeThemePage",
          builder: (context, state) {
            return const ChangeThemePage();
          }),
      GoRoute(
          path: '/singleChatPage',
          name: "singleChatPage",
          pageBuilder: (context, state) {
            final friend = state.extra as Friend;
            return CustomTransitionPage(
              child: BlocProvider(
                create: (context) => SingleChatBloc(),
                child: SingleChatPage(
                  friend: friend,
                ),
              ),
              transitionDuration: const Duration(milliseconds: 1000),
              transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) {
                // 淡入淡出 + 缩放动画
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
            );
          },
          routes: [
            GoRoute(
                path: "singleChatInfo",
                name: "singleChatInfo",
                builder: (context, state) {
                  final dataMap = state.extra as Map<String, dynamic>;
                  final chatItem = dataMap['chatItem'];
                  final singleChatBloc = dataMap['singleChatBloc'];
                  return SingleChatInfoPage(
                    chatItem: chatItem,
                    singleChatBloc: singleChatBloc,
                  );
                })
          ]),
      GoRoute(
          path: "/groupChatPage",
          name: "groupChatPage",
          builder: (context, state) {
            final groupUid = state.extra as String;
            return BlocProvider(
              create: (context) => GroupChatBloc(),
              child: GroupChatPage(groupUid: groupUid),
            );
          }),
      GoRoute(
        path: '/friendInfo',
        name: 'friendInfo',
        builder: (context, state) {
          final friendId = state.extra as String;
          return BlocProvider(
            create: (context) => serviceLocator.get<FriendInfoBloc>(),
            child: FriendInfoPage(
              friendUid: friendId,
            ),
          );
        },
        routes: [
          GoRoute(
              path: 'friendSettings',
              name: 'friendSettings',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: data['friendInfoBloc'] as FriendInfoBloc,
                    ),
                    BlocProvider.value(
                      value: serviceLocator.get<ContactListBloc>(),
                    )
                  ],
                  child: FriendSettingsPage(
                    friend: data['friend'] as Friend,
                  ),
                );
              }),
          GoRoute(
              name: 'updateAlias',
              path: 'updateAlias',
              builder: (context, state) {
                final map = state.extra as Map<String, dynamic>;
                return BlocProvider.value(
                  value: map['friendInfoBloc'] as FriendInfoBloc,
                  child: SetFriendAliasPage(
                    friendUid: map['friendUid'],
                    alias: map['alias'],
                  ),
                );
              }),
        ],
      ),
      GoRoute(
        path: "/requestFriendList",
        name: "requestFriendList",
        builder: (context, state) {
          return BlocProvider.value(
            value: serviceLocator.get<FriendRequestListBloc>(),
            child: const FriendRequestListPage(),
          );
        },
        routes: [
          GoRoute(
            path: "acceptRequest",
            name: "acceptRequest",
            builder: (context, state) {
              Map<String, dynamic> map = state.extra as Map<String, dynamic>;
              String? requestMessage = map['requestMessage'];
              String friendUid = map['friendUid'];
              return BlocProvider.value(
                value: serviceLocator.get<ContactListBloc>(),
                child: AcceptRequestPage(
                  requestMessage: requestMessage,
                  friendUid: friendUid,
                ),
              );
            },
          ),
          GoRoute(
            path: "requestFriendInfo",
            name: "requestFriendInfo",
            builder: (context, state) {
              final requestUserId = state.extra as String;
              return BlocProvider(
                create: (context) =>
                    serviceLocator.get<RequestFriendInfoBloc>(),
                child: RequestFriendInfoPage(
                  requestUseId: requestUserId,
                ),
              );
            },
          )
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => BlocProvider.value(
          value: serviceLocator.get<SettingsBloc>(),
          child: const Settings(),
        ),
        routes: const [],
      ),
      GoRoute(
        path: "/photoView",
        name: "photoView",
        builder: (context, state) {
          final dataMap = state.extra as Map<String, dynamic>;
          final imagePath = dataMap['imagePath'];
          final imageUrl = dataMap['imageUrl'];
          return ChatPhotoView(
            imagePath: imagePath,
            imageUrl: imageUrl,
          );
        },
      ),
      GoRoute(
          path: "/photoGallery",
          name: "photoGallery",
          builder: (context, state) {
            final dataMap = state.extra as Map<String, dynamic>;
            final List<String> imageList = dataMap['imageList'] as List<String>;
            final int initialIndex = dataMap['initialIndex'] as int;
            return CustomPhotoGallery(
              imagePathList: imageList,
              initialIndex: initialIndex,
            );
          }),
      GoRoute(
          path: "/takePhotoResult",
          name: "takePhotoResult",
          builder: (context, state) {
            final imagePath = state.extra as String;
            return TakePhotoResultPage(filePath: imagePath);
          }),
      GoRoute(
        path: "/sendFile",
        name: 'sendFile',
        builder: (context, state) {
          final friendUid = state.extra as String;
          return BlocProvider.value(
            value: serviceLocator.get<SendFileBloc>(),
            child: SendFilePage(friendUid: friendUid),
          );
        },
      ),
      GoRoute(
        path: "/receiveFile",
        name: "receiveFile",
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final fileList = data['fileList'] as List<Map<String, String>>;
          final friendUid = data['friendUid'] as String;
          final fileListHashCode = data['fileListHashCode'] as int;
          return BlocProvider.value(
            value: serviceLocator.get<ReceiveFileBloc>(),
            child: ReceiveFilePage(
              fileList: fileList,
              friendUid: friendUid,
              fileListHashCode: fileListHashCode,
            ),
          );
        },
      ),
      GoRoute(
        path: "/testPage",
        name: "testPage",
        builder: (context, state) {
          return TestPage();
        },
      ),
    ],
  );
}
