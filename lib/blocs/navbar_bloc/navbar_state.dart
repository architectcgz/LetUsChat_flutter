part of 'navbar_bloc.dart';

@immutable
sealed class NavbarState {}

final class NavbarInitial extends NavbarState {}

final class NavbarBadgeUpdated extends NavbarState{
  final List<bool> badgeList;
  NavbarBadgeUpdated({required this.badgeList});
}

final class LoadBadgeSucceed extends NavbarState{
  final List<bool> badgeList;
  LoadBadgeSucceed({required this.badgeList});
}