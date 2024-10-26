import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'send_file_event.dart';
part 'send_file_state.dart';

class SendFileBloc extends Bloc<SendFileEvent, SendFileState> {
  int? fileListHashCode;
  String? friendUid;
  SendFileBloc() : super(SendFileInitial()) {
    on<SendFileEvent>((event, emit) {

    });
    on<FriendAcceptFileReqEvent>((event,emit){
      fileListHashCode = event.fileListHashCode;
      friendUid = event.friendUid;
      emit(FriendHasAcceptedReq());
    });
  }
}
