import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecte_pm/services/user_data_service.dart';
import 'package:projecte_pm/models/user/user.dart' as models;
import 'package:projecte_pm/models/artist/artist.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserDataService _dataService = UserDataService();

  bool _isLoading = true;

  String _userName = "Carregant...";
  String _userEmail = "correu@exemple.cat";
  bool _isArtist = false;
  dynamic _userProfile;

  // Contingut (reutilitzem el mateix format que LandingPage)
  List<Map<String, dynamic>> _savedPlaylistsAndAlbums = [];
  List<Map<String, dynamic>> _artistAlbums = [];

  // Estat de cerca i filtres (com a la imatge)
  String _searchQuery = "";
  int _selectedFilter = 0; // 0 Totes, 1 Per àlbum, 2 Per artista, 3 Per llista

  final List<String> _filters = [
    "Totes",
    "Per àlbum",
    "Per artista",
    "Per llista",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      _userEmail = currentUser.email ?? _userEmail;

      final data = await _dataService.loadLandingPageData();

      if (!mounted) return;

      if (!data['profileFound']) {
        setState(() {
          _userName =
              currentUser.displayName ?? _userEmail.split('@').first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = data['userName'] ?? 'Usuari';
          _isArtist = data['isArtist'] ?? false;
          _userProfile = data['profile'];

          if (_isArtist) {
            _artistAlbums = data['artistAlbums'] ?? [];
          } else {
            _savedPlaylistsAndAlbums = data['savedContent'] ?? [];
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error carregant dades a UsersPage: $e");
      if (!mounted) return;
      setState(() {
        _userName =
            currentUser.displayName ?? _userEmail.split('@').first;
        _isLoading = false;
      });
    }
  }

  // --------- HELPERS DE DADES / FILTRE ----------

  List<Map<String, dynamic>> _getBaseItems() {
    if (_isArtist) {
      // Per un artista, mostrem els seus àlbums publicats com a “llistes”
      return _artistAlbums
          .map((album) => {
                ...album,
                'type': 'album_published',
                'name': album['title'] ?? album['name'] ?? 'Àlbum',
                'numSongs': album['tracks']?.length ?? album['numSongs'],
              })
          .toList();
    } else {
      return _savedPlaylistsAndAlbums;
    }
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> items) {
    // Filtre per tipus base
    List<Map<String, dynamic>> filtered = items.where((item) {
      final type = (item['type'] ?? '').toString();

      switch (_selectedFilter) {
        case 1: // Per àlbum
          return type.contains('album');
        case 2: // Per artista (els àlbums també solen tenir artista)
          return type.contains('album');
        case 3: // Per llista
          return type.contains('playlist');
        default:
          return true; // Totes
      }
    }).toList();

    // Filtre per text de cerca
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        final name =
            (item['name'] ?? item['title'] ?? '').toString().toLowerCase();
        return name.contains(q);
      }).toList();
    }

    return filtered;
  }

  // --------- WIDGETS UI (seguint la foto) ----------

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 4),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(
            Icons.person,
            size: 55,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userEmail,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: TextField(
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: 'Cerca cançons',
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final selected = _selectedFilter == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_filters[index]),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedFilter = index);
                },
                selectedColor: const Color(0xFF1DB954),
                backgroundColor: const Color(0xFFF3F3F3),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMyListsSection() {
    final baseItems = _getBaseItems();
    final items = _applyFilters(baseItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Les meves llistes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text(
            'Encara no tens llistes ni àlbums.',
            style: TextStyle(color: Colors.grey),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final name =
                  (item['name'] ?? item['title'] ?? 'Sense nom').toString();
              final numSongs =
                  item['numSongs'] ?? item['tracks']?.length ?? 10; // placeholder

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$numSongs cançons',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botó verd "Seguir", com a la maqueta
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        // TODO: afegir lògica de seguir / deixar de seguir
                      },
                      child: const Text(
                        'Seguir',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ----------------- BUILD -----------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterRow(),
            _buildMyListsSection(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navegar a "Editar perfil" si cal
                },
                child: const Text(
                  'Editar perfil',
                  style: TextStyle(
                    color: Color(0xFF1DB954),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
