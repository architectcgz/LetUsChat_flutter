part of 'global_user_bloc.dart';

@immutable
sealed class GlobalUserEvent {}

final class SaveGlobalUserInfoEvent extends GlobalUserEvent{
  final User user;
  SaveGlobalUserInfoEvent({required this.user});
}

final class LoadGlobalUserInfoEvent extends GlobalUserEvent{

}

final class UploadAvatarEvent extends GlobalUserEvent{
  final File file;
  UploadAvatarEvent({required this.file});
}

final class UpdateGlobalUserInfoEvent extends GlobalUserEvent{
  final User newUser;
  UpdateGlobalUserInfoEvent({required this.newUser});
}


final class UpdateSignatureEvent extends GlobalUserEvent{
  final String newSignature;
  UpdateSignatureEvent({required this.newSignature});
}

final class UpdateUsernameEvent extends GlobalUserEvent {
  final String username;
  UpdateUsernameEvent({required this.username});
}

final class UpdateLocationEvent extends GlobalUserEvent{
  final String newLocation;
  UpdateLocationEvent({required this.newLocation});
}

final class UpdateGenderEvent extends GlobalUserEvent{
  final int newGender;
  UpdateGenderEvent({required this.newGender});
}