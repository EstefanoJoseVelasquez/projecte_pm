class UserSavedAlbum {
  final String _id; //No modificable
  final String _albumId;
  final DateTime _savedAt; //No modificable

  //Constructor
  UserSavedAlbum({required String id, required String albumId})
    : _id = id,
      _albumId = albumId,
      _savedAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get albumId => _albumId;
  DateTime get savedAt => _savedAt;
}
