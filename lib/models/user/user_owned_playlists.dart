class UserOwnedPlaylist {
  final String _id; //No modificable
  final String _playlistId;
  final DateTime _createdAt; //No modificable

  //Constructor
  UserOwnedPlaylist({required String id, required String playlistId})
    : _id = id,
      _playlistId = playlistId,
      _createdAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get playlistId => _playlistId;
  DateTime get createdAt => _createdAt;
}
