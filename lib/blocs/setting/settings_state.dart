part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();
}

final class SettingInitial extends SettingsState {
  @override
  List<Object> get props => [];
}
