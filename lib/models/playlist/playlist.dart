class Playlist {
  final String _id;
  String _name;
  String _description;
  final String _ownerId;
  String _coverURL;
  bool _isPublic;
  bool _isCollaborative;
  DateTime _updatedAt;
  final DateTime _createdAt;

  //Constructor
  Playlist({
    required String id,
    required String name,
    String? description,
    required String ownerId,
    String? coverURL,
    bool? isPublic,
    bool? isCollaborative,
  }) : _id = id,
       _name = name,
       _description = description ?? '',
       _ownerId = ownerId,
       _coverURL = coverURL ?? '',
       _isPublic = isPublic ?? false,
       _isCollaborative = isCollaborative ?? false,
       _updatedAt = DateTime.now(),
       _createdAt = DateTime.now();

  //Llista de getters
  String get id => _id;
  String get name => _name;
  String get ownerId => _ownerId;
  String get coverURL => _coverURL;
  bool get isPublic => _isPublic;
  bool get isCollaborative => _isCollaborative;
  DateTime get updatedAt => _updatedAt;
  DateTime get createdAt => _createdAt;

  //Llista de Setters
  set name(String name) => _name = name;
  set coverURL(String coverURL) => _coverURL = coverURL;
  set isPublic(bool isPublic) => _isPublic = isPublic;
  set isCollaborative(bool isCollabo) => _isCollaborative = isCollabo;
}
