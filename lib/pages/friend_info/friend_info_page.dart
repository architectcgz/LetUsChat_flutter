import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/widgets/app_bar_with_more.dart';
import '../../blocs/friend_info/friend_info_bloc.dart';
import 'package:flutter/material.dart';
import '../../repository/models/friend.dart';

class FriendInfoPage extends StatefulWidget {
  final String friendUid;
  const FriendInfoPage({super.key, required this.friendUid});

  @override
  State<FriendInfoPage> createState() => _FriendInfoState();
}

class _FriendInfoState extends State<FriendInfoPage> {
  late Friend _friend;
  late final String _friendUid;
  late final FriendInfoBloc _friendInfoBloc;
  @override
  void initState() {
    super.initState();
    _friendUid = widget.friendUid;
    _friendInfoBloc = context.read<FriendInfoBloc>();
    _friendInfoBloc.add(LoadFriendInfoEvent(friendId: _friendUid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendInfoBloc, FriendInfoState>(
      listener: (context, state) {},
      builder: (context, state) {
        VoidCallback? onPressed;

        if (state is LoadFriendInfoSucceed) {
          onPressed = () {
            GoRouter.of(context).pushNamed("friendSettings",
                extra: {'friend': _friend, 'friendInfoBloc': _friendInfoBloc});
          };
        }

        return Scaffold(
          appBar: AppBarWithMore(
            title: "好友信息",
            onPressed: onPressed,
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(FriendInfoState state) {
    // 在这两个状态下更新 _friend
    if (state is FriendInfoLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is LoadFriendInfoSucceed) {
      _friend = state.friend;
      return ListView(
        children: [
          _buildHeader(_friend),
          _buildOptions(context, _friend),
          _buildMomentSection(), // 朋友圈
          _buildMoreInfoButton(),
          _buildBottomActions(state),
        ],
      );
    } else if (state is AliasUpdated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _friend.alias = state.newAlias;
        });
      });
      return ListView(
        children: [
          _buildHeader(_friend),
          _buildOptions(context, _friend),
          _buildMomentSection(), // 朋友圈
          _buildMoreInfoButton(),
          _buildBottomActions(state),
        ],
      );
    } else if (state is LoadFriendInfoFailed) {
      return Center(child: Text('加载失败，请重试: ${state.message}'));
    }
    return const Text("其他状态");
  }

  Widget _buildHeader(Friend friend) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(friend.avatar),
            radius: 40.0,
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.alias ?? friend.nickname,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text("昵称: ${friend.nickname}"),
              Text("UID: ${friend.userId}"),
              Text("地区: ${friend.location ?? '未设置'}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context, Friend friend) {
    return Column(
      children: [
        ListTile(
          title: const Text('设置备注'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            GoRouter.of(context)
                .pushNamed("updateAlias", extra: <String, dynamic>{
              'friendInfoBloc': _friendInfoBloc,
              'friendUid': friend.userId,
              'alias': friend.alias ?? friend.nickname
            });
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('朋友权限'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Handle tap
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildMomentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('朋友圈'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            GoRouter.of(context).pushNamed("unimplementedPage");
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildMoreInfoButton() {
    return ListTile(
      title: const Text('更多信息'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Handle tap
      },
    );
  }

  Widget _buildBottomActions(FriendInfoState state) {
    if (state is LoadDeletedFriendInfoSucceed) {}
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text('发消息'),
            onPressed: () {
              GoRouter.of(context).pushNamed("singleChatPage", extra: _friend);
            },
          ),
          const SizedBox(height: 10.0),
          ElevatedButton.icon(
            icon: const Icon(Icons.videocam),
            label: const Text('音视频通话'),
            onPressed: () {
              // Handle video call
            },
          ),
        ],
      ),
    );
  }
}
