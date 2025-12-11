import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecte_pm/services/user_data_service.dart';
import 'package:projecte_pm/widgets/history_list.dart';
import 'package:projecte_pm/models/user/user.dart' as models;
import 'package:projecte_pm/models/artist/artist.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final UserDataService _dataService = UserDataService();

  // --- Estat del Widget ---
  int _currentIndex = 0;
  bool _isLoading = true;

  String _userName = "Carregant...";
  dynamic _userProfile;
  bool _isArtist = false;
  List<Map<String, dynamic>> _savedPlaylistsAndAlbums = [];
  List<Map<String, dynamic>> _playHistory = [];
  List<Map<String, dynamic>> _artistAlbums = []; // Afegit per si ets Artista

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // --- Funció de Càrrega (Crida al Servei) ---
  Future<void> _loadAllData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      return;
    }
    try {
      final data = await _dataService.loadLandingPageData();

      if (mounted) {
        if (!data['profileFound']) {
          // Usuari Auth sense perfil Firestore
          setState(() {
            _userName =
                currentUser.displayName ?? currentUser.email!.split('@').first;
            _isLoading = false;
          });
        } else {
          // Perfil trobat, actualitzem l'estat amb els Models i Llistes
          setState(() {
            _userName = data['userName'] ?? 'Usuari';
            _isArtist = data['isArtist'];
            _userProfile = data['profile'];

            if (_isArtist) {
              _artistAlbums = data['artistAlbums'] ?? [];
            } else {
              _savedPlaylistsAndAlbums = data['savedContent'] ?? [];
              _playHistory = data['history'] ?? [];
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error durant la càrrega de dades: $e");
      if (mounted) {
        setState(() {
          _userName =
              currentUser.displayName ?? currentUser.email!.split('@').first;
          _isLoading = false;
        });
      }
    }
  }

  // --- Mètodes auxiliars (de presentació) ---

  String _getCoverUrl(Map<String, dynamic> item) {
    // S'ha de gestionar l'àlbum d'artista si cal (afegit a _buildSavedContentGrid)
    return item['coverURL'] ??
        item['image'] ??
        'https://via.placeholder.com/55?text=Cover';
  }

  String _getSubTitle(Map<String, dynamic> item) {
    if (item['type'] == 'album_saved' || item['type'] == 'album_published')
      return 'Àlbum';
    if (item['type'] == 'playlist_owned') return 'Playlist (Teua)';
    if (item['type'] == 'playlist_saved') return 'Playlist Guardada';
    return 'Element Desconegut';
  }

  Widget _buildSavedContentGrid({bool isArtist = false}) {
    final items = isArtist ? _artistAlbums : _savedPlaylistsAndAlbums;

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Icon(
            Icons.library_music_outlined,
            size: 40,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 8),
          Text(
            isArtist
                ? 'No has publicat cap àlbum.'
                : 'Comença a guardar música!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    // El GridView.builder real
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 8 / 2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        // Per als àlbums d'artista, cal adaptar el Map
        final displayItem = isArtist
            ? {
                ...item,
                'type': 'album_published',
                'name': item['title'] ?? item['name'] ?? 'Àlbum publicat',
              }
            : item;

        return InkWell(
          onTap: () {
            print("Clic a ${displayItem['name']}");
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    _getCoverUrl(displayItem),
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 55,
                      height: 55,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayItem['name'] ?? 'Sense nom',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getSubTitle(displayItem),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    // Extracció de dades riques del model
    String profileBio = 'Sense bio';

    // 💥 CORRECCIÓ CLAU: Utilitzem models.User
    if (_userProfile != null) {
      if (_isArtist) {
        profileBio = (_userProfile as Artist).bio;
      } else {
        profileBio = (_userProfile as models.User).bio;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF121212),
        titleSpacing: 0,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/img/logo.png'),
              ),
            ),
            Text(
              "Hola, $_userName",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Utilització de la BIO del teu Model
              Text(
                _isArtist
                    ? 'Rol: Artista | Bio: $profileBio'
                    : 'Rol: Usuari | Bio: $profileBio',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 15),

              if (_isArtist) ...[
                const Text(
                  'Els teus Àlbums Publicats:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildSavedContentGrid(isArtist: true),
                const SizedBox(height: 30),
              ] else ...[
                const Text(
                  'El teu contingut Guardat:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildSavedContentGrid(),
                const SizedBox(height: 30),

                // --- SECCIÓ TORNA A ESCOLTAR (HISTORIAL) ---
                if (_playHistory.isNotEmpty) ...[
                  const Text(
                    'Torna a escoltar:',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  HistoryList(history: _playHistory),
                  const SizedBox(height: 15),
                ],
              ],

              const Text(
                "Novetats per a tu",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 100), // Espaiat final
            ],
          ),
        ),
      ),

      // --- BARRA DE NAVEGACIÓ INFERIOR ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inici"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cerca"),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: "Biblioteca",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Crea"),
        ],
      ),
    );
  }
}
