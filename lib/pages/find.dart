import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/find/find_bloc.dart';
import 'package:let_us_chat/widgets/app_bar_with_search.dart';

class Find extends StatefulWidget {
  const Find({super.key});
  @override
  State<Find> createState() => _FindState();
}

class _FindState extends State<Find> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindBloc, FindState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBarWithSearch(
              title: "发现",
            ),
          );
        },
        listener: (context, state) {});
  }
}
