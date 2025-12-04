class PlaylistCollaborator {
  final String _id;
  final String _userId;
  String _userName;
  bool _canEdit;
  final DateTime _addedAt;

  //Constructor
  PlaylistCollaborator({
    required String id,
    required String userId,
    required String userName,
    bool? canEdit,
  }) : _id = id,
       _userId = userId,
       _userName = userName,
       _canEdit = canEdit ?? false,
       _addedAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get userId => _userId;
  String get userName => _userName;
  bool get canEdit => _canEdit;
  DateTime get addedAt => _addedAt;

  //Llista de setters
  set userName(String userName) => _userName = userName;
  set canEdit(bool canEdit) => _canEdit = canEdit;
}
