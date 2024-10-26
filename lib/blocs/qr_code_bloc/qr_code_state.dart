part of './qr_code_bloc.dart';

sealed class QrCodeState extends Equatable {
  const QrCodeState();
}

final class QrCodeInitial extends QrCodeState {
  @override
  List<Object> get props => [];
}

final class QrCodeLoading extends QrCodeState {
  @override
  List<Object?> get props => [];
}

final class QrCodeLoaded extends QrCodeState {
  // 将 Base64 字符串转换为 Uint8List
  final Uint8List qrCodeBytes;

  const QrCodeLoaded(this.qrCodeBytes);

  @override
  List<Object> get props => [qrCodeBytes];
}

final class QrCodeError extends QrCodeState {
  final String message;

  const QrCodeError(this.message);

  @override
  List<Object> get props => [message];
}
