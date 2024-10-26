import 'package:equatable/equatable.dart';

final class CustomException extends Equatable implements Exception {
  final String message;
  final int code;
  const CustomException({
    required this.code,
    required this.message,
  });
  @override
  List<Object?> get props => [message, code];
}

