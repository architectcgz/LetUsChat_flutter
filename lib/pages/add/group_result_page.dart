import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/add_friend_group/add_friend_group_bloc.dart';
import '../../repository/models/group.dart';
import '../../widgets/app_bar_with_title_arrow.dart';

class GroupResultPage extends StatefulWidget {
  final Group group;

  const GroupResultPage({super.key, required this.group});
  @override
  State<GroupResultPage> createState() => _GroupResultPageState();
}

class _GroupResultPageState extends State<GroupResultPage> {
  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return BlocConsumer<AddFriendGroupBloc, AddFriendGroupState>(
      listener: (context, state) {},
      builder: (context, state) {
        return const Scaffold(
          appBar: AppBarWithTitleAndArrow(),
          body: Column(),
        );
      },
    );
  }
}
