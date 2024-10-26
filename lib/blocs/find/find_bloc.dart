import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'find_event.dart';
part 'find_state.dart';

class FindBloc extends Bloc<FindEvent, FindState> {
  FindBloc() : super(FindInitial()) {
    on<FindEvent>((event, emit) {
      print("查找事件的handler还没有完成!!");
    });
  }
}
