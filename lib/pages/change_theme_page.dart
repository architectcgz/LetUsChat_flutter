import 'package:flutter/material.dart';
import 'package:let_us_chat/blocs/theme_bloc/theme_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

import '../styles/app_themes.dart';

class ChangeThemePage extends StatelessWidget {
  const ChangeThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = serviceLocator.get<ThemeBloc>();

    return Scaffold(
      appBar: const AppBarWithTitleAndArrow(
        title: "自定义主题",
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('选择主题:'),
            ElevatedButton(
              onPressed: () {
                _handleThemeChange(context, themeBloc, AppThemes.lightTheme,
                    '当前系统主题为深色模式,切换为此主题可能不显示,请先关闭系统深色模式后再试');
              },
              child: const Text('浅色模式'),
            ),
            ElevatedButton(
              onPressed: () {
                themeBloc.add(ChangeThemeEvent(theme: AppThemes.darkTheme));
              },
              child: const Text('深色模式'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleThemeChange(context, themeBloc, AppThemes.greenTheme,
                    '当前系统主题为深色模式,切换为此主题可能不显示,请先关闭系统深色模式后再试');
              },
              child: const Text('绿色主题'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleThemeChange(context, themeBloc, AppThemes.brownTheme,
                    '当前系统主题为深色模式,切换为此主题可能不显示,请先关闭系统深色模式后再试');
              },
              child: const Text('棕色主题'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleThemeChange(context, themeBloc, AppThemes.purpleTheme,
                    '当前系统主题为深色模式,切换为此主题可能不显示,请先关闭系统深色模式后再试');
              },
              child: const Text('紫色主题'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleThemeChange(BuildContext context, ThemeBloc themeBloc,
      ThemeData theme, String confirmationMessage) {
    var systemTheme = MediaQuery.of(context).platformBrightness;

    if (systemTheme == Brightness.dark) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('确定切换'),
            content:
                Text(confirmationMessage, style: const TextStyle(fontSize: 18)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  themeBloc.add(ChangeThemeEvent(theme: theme));
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('确认'),
              ),
            ],
          );
        },
      );
    } else {
      themeBloc.add(ChangeThemeEvent(theme: theme));
    }
  }
}
