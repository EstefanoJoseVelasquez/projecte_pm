class UserSavedPlaylist {
  final String _id; //No modificable
  final String _playlistId;
  final DateTime _savedAt; //No modificable

  //Constructor
  UserSavedPlaylist({required String id, required String playlistId})
    : _id = id,
      _playlistId = playlistId,
      _savedAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get playlistId => _playlistId;
  DateTime get savedAt => _savedAt;
}
