import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../styles/app_themes.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeName = prefs.getString('theme') ?? 'light';
    if (themeName == 'dark') {
      add(ChangeThemeEvent(theme: AppThemes.darkTheme));
    } else if (themeName == 'green') {
      add(ChangeThemeEvent(theme: AppThemes.greenTheme));
    } else {
      add(ChangeThemeEvent(theme: AppThemes.lightTheme));
    }
  }

  void _saveTheme(String themeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeName);
  }

  ThemeBloc() : super(ThemeInitial(themeData: AppThemes.lightTheme)) {
    _loadTheme();
    on<ChangeThemeEvent>((event, emit) async {
      emit(ThemeChanged(themeData: event.theme));
      //保存修改后的主题
      if (event.theme == AppThemes.darkTheme) {
        _saveTheme('dark');
      } else if (event.theme == AppThemes.greenTheme) {
        _saveTheme('green');
      } else {
        _saveTheme('light');
      }
    });
  }
}
