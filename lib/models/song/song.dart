class Song {
  final String _id;
  String _name;
  final String _artistId; //Només un artista principal
  final List<String> _colaboratorsId; //Pot tenir mes d'un colaborador
  final List<String> _albumId; //Pot estar en mes d'un album
  double _duration;
  String _fileURL;
  String _coverURL;
  final List<String> _genre;
  bool _isPublic;
  String _lyrics;
  final DateTime _createdAt;

  //Constructor
  Song({
    required String id,
    required String name,
    required String artistId,
    List<String>? colaboratorsId,
    List<String>? albumId,
    required double duration,
    required String fileURL,
    required String coverURL,
    List<String>? genre,
    bool? isPublic,
    String? lyrics,
  }) : _id = id,
       _name = name,
       _artistId = artistId,
       _colaboratorsId = colaboratorsId ?? [],
       _albumId = albumId ?? [],
       _duration = duration,
       _fileURL = fileURL,
       _coverURL = coverURL,
       _genre = genre ?? [],
       _isPublic = isPublic ?? false,
       _lyrics = lyrics ?? '',
       _createdAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get name => _name;
  String get artistId => _artistId;
  double get duration => _duration;
  String get fileURL => _fileURL;
  String get coverURL => _coverURL;
  bool get isPublic => _isPublic;
  String get lyrics => _lyrics;
  DateTime get createdAt => _createdAt;

  //Llista de Setters
  set name(String name) => _name = name;
  set duration(double duration) => _duration = duration;
  set fileURL(String fileURL) => _fileURL = fileURL;
  set coverURL(String coverURL) => _coverURL = coverURL;
  set isPublic(bool isPublic) => _isPublic = isPublic;
  set lyrics(String lyrics) => _lyrics = lyrics;

  //Metodes per colaboratosId
  void addColaboratorsId(String id) => _colaboratorsId.add(id);
  void removeColaboratorsId(String id) => _colaboratorsId.remove(id);

  //Metodes per albumId
  void addAlbumId(String id) => _albumId.add(id);
  void removeAlbumId(String id) => _albumId.remove(id);

  //Metodes per genre
  void addGenre(String genre) => _genre.add(genre);
  void removeGenre(String genre) => _genre.remove(genre);
}
