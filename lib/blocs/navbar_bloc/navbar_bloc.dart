import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/utils/shared_preference_utils.dart';

part 'navbar_event.dart';
part 'navbar_state.dart';

class NavbarBloc extends Bloc<NavbarEvent, NavbarState> {
  List<bool> badgeList = [];
  GlobalUserBloc globalUserBloc = serviceLocator.get<GlobalUserBloc>();

  NavbarBloc() : super(NavbarInitial()) {
    String key = navbarBadgeKey + globalUserBloc.globalUser!.userId;
    on<LoadBadgeEvent>((event, emit) async {
      badgeList = await SharedPreferenceUtil.getBoolList(key) ??
          [false, false, false, false];
      emit(LoadBadgeSucceed(badgeList: badgeList));
    });
    on<SaveBadgeEvent>((event, emit) async {
      await SharedPreferenceUtil.saveBoolList(key, event.badgeList);
    });
    on<UpdateBadgeEvent>((event, emit) async {
      badgeList = event.badgeList;
      add(SaveBadgeEvent(badgeList: badgeList));
      emit(NavbarBadgeUpdated(badgeList: badgeList));
    });
  }
}
