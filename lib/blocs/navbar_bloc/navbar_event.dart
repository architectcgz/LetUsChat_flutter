part of 'navbar_bloc.dart';

@immutable
sealed class NavbarEvent extends Equatable {}

final class LoadBadgeEvent extends NavbarEvent{
  @override
  List<Object?> get props => [];
}

final class SaveBadgeEvent extends NavbarEvent{
  final List<bool> badgeList;
  SaveBadgeEvent({required this.badgeList});
  @override
  List<Object?> get props => [];
}

final class UpdateBadgeEvent extends NavbarEvent{
  final List<bool> badgeList;
  UpdateBadgeEvent({required this.badgeList});

  @override
  List<Object?> get props => [];
}