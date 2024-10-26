part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent extends Equatable{}

final class ChangeThemeEvent extends ThemeEvent {
  final ThemeData theme;

  ChangeThemeEvent({required this.theme});
  @override
  List<Object?> get props => [theme];
}
