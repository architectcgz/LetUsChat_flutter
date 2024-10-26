import 'package:equatable/equatable.dart';
import 'package:let_us_chat/core/errors/exception.dart';

class Failure extends Equatable {
  final String message;
  final int code;

  String get errorMessage =>
      'ErrorType:$runtimeType StatusCode:$code ErrorMessage:$message';
  const Failure({
    required this.message,
    required this.code,
  });

  @override
  List<Object> get props => [message, code];

  Failure.fromException(CustomException e)
  :this(
    message: e.message,
    code: e.code
  );
}