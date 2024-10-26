part of 'qr_code_bloc.dart';

sealed class QrCodeEvent extends Equatable {
  const QrCodeEvent();
}

final class FetchQRCode extends QrCodeEvent{
  @override
  List<Object?> get props => [];
}