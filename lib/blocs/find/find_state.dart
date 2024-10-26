part of 'find_bloc.dart';

sealed class FindState extends Equatable {
  const FindState();
}

final class FindInitial extends FindState {
  @override
  List<Object> get props => [];
}
