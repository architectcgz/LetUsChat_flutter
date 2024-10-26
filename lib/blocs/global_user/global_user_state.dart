part of 'global_user_bloc.dart';

@immutable
sealed class GlobalUserState {}

final class GlobalUserInitial extends GlobalUserState {}

final class UpdateAvatarSucceed extends GlobalUserState{}
final class UpdateAvatarFailed extends GlobalUserState{

}


final class UploadingAvatar extends GlobalUserState{}

final class UploadAvatarSucceed extends GlobalUserState {}

final class UploadAvatarFailed extends GlobalUserState {
  final String message;
  final DateTime timestamp;
  UploadAvatarFailed({required this.message})
      : timestamp = DateTime.timestamp();
}

final class UpdateUserInfoFailed extends GlobalUserState{
  final String message;
  final DateTime timestamp;
  UpdateUserInfoFailed({required this.message}):timestamp = DateTime.timestamp();
}

final class UpdateUserInfoSucceed extends GlobalUserState{}

final class SignatureExceedLength extends GlobalUserState{}

final class UpdateSignatureFailed extends GlobalUserState{
  final String message;
  UpdateSignatureFailed({required this.message});
}

final class UpdateSignatureSucceed extends GlobalUserState{
  UpdateSignatureSucceed();
}


final class UpdateUsernameSucceed extends GlobalUserState{
  UpdateUsernameSucceed();
}

final class UpdateUsernameFailed extends GlobalUserState{
  final String message;
  UpdateUsernameFailed({required this.message});
}

final class UsernameExceedLength extends GlobalUserState{

}

final class UpdateGenderSucceed extends GlobalUserState{

}

final class UpdateGenderFailed extends GlobalUserState{
  final String message;
  UpdateGenderFailed({required this.message});
}

final class UpdateLocationSucceed extends GlobalUserState{

}

final class UpdateLocationFailed extends GlobalUserState{
  final String message;
  UpdateLocationFailed({required this.message});
}

