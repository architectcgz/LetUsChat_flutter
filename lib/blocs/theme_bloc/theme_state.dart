part of 'theme_bloc.dart';

@immutable
class ThemeState {
  final ThemeData themeData;
  const ThemeState({required this.themeData});
}

final class ThemeInitial extends ThemeState {
  const ThemeInitial({required super.themeData});
}

final class ThemeChanged extends ThemeState{
  const ThemeChanged({required super.themeData});

}