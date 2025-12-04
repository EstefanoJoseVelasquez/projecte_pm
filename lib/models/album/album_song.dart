class AlbumSong {
  final String _id;
  String _songId;
  String _name;
  int _trackNumber;
  double _duration;
  final DateTime _addedAt;

  //Constructor
  AlbumSong({
    required String id,
    required String songId,
    required String name,
    required int trackNumber,
    required double duration,
  }) : _id = id,
       _songId = songId,
       _name = name,
       _trackNumber = trackNumber,
       _duration = duration,
       _addedAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get songId => _songId;
  String get name => _name;
  int get trackNumber => _trackNumber;
  double get duration => _duration;
  DateTime get addedAt => _addedAt;

  //Llista de setters
  set songId(String songId) => _songId = songId;
  set name(String name) => _name = name;
  set trackNumber(int trackNumber) => _trackNumber = trackNumber;
  set duration(double duration) => _duration = duration;
}
