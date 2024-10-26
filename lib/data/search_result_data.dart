
import '../repository/models/friend.dart';
import '../repository/models/group.dart';

class SearchResultData {
  final List<Friend>? friends;
  final List<Group>? groups;

  SearchResultData({this.friends, this.groups});
}
