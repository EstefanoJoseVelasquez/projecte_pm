class ArtistFollower {
  final String _id;
  final String _userId;
  final DateTime _followedAt;

  //Constructor
  ArtistFollower({required String id, required String userId})
    : _id = id,
      _userId = userId,
      _followedAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get userId => _userId;
  DateTime get followedAt => _followedAt;
}
