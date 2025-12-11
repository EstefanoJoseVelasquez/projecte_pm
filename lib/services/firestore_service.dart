// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBauth;
import 'package:projecte_pm/models/artist/artist.dart'; 
import 'package:projecte_pm/models/user/user.dart'; 

// Es fa 'final' per garantir que sigui una sola instància (Singleton)
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> createUserOrArtistProfile(FBauth.User user, bool isArtist, String name) async {
  final String uid = user.uid;
  final String email = user.email ?? '';

  if (isArtist) {
    // Crear Artista
    await _firestore.collection('artists').doc(uid).set({
      'name': name,
      'email': email,
      'bio': '',
      'photoURL': user.photoURL ?? '',
      'verified': false,
      'stats': {'followers': 0, 'totalPlays': 0, 'monthlyListeners': 0, 'totalTracks': 0, 'totalAlbums': 0},
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } else {
    // Crear Usuari Estàndard
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'photoURL': user.photoURL ?? '',
      'bio': '',
      'stats': {'followers': 0, 'following': 0},
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
// Funció principal per omplir la base de dades
Future<void> createSampleData(String userId, String userName) async {
  print('Iniciant creació de dades de mostra per a l\'usuari: $userId');

  // --- 0. Referència al document de l'usuari ---
  final userRef = _firestore.collection('users').doc(userId);
  final now = FieldValue.serverTimestamp();
  final fixedDate = DateTime.now();

  // --- 1. Crear Artista de Prova ---
  final artistId = 'artist_dua_upc';
  final artistRef = _firestore.collection('artists').doc(artistId);
  await artistRef.set({
    'name': 'Dua UPC',
    'bio': 'L\'artista més popular de l\'FNB.',
    'email': 'dua@upc.edu',
    'photoURL': 'https://placehold.co/200?text=Dua+UPC',
    'coverURL': 'https://placehold.co/400x150?text=Dua+UPC+Banner',
    'verified': true,
    'label': 'UPC Records',
    'manager': 'Manel Manager',
    'genre': ['Pop', 'Dance'],
    'socialLinks': {'instagram': '@DuaUPC', 'website': 'http://upc.edu'},
    'stats': {
      'followers': 1000,
      'totalPlays': 500000,
      'monthlyListeners': 50000,
      'totalTracks': 2,
      'totalAlbums': 1,
    },
    'createdAt': now,
  });
  print('   - 1 Artista (Dua UPC) creat.');

  // --- 2. Crear Àlbum de Prova ---
  final albumId1 = 'album_nostalgia_upc';
  final albumRef1 = _firestore.collection('albums').doc(albumId1);
  await albumRef1.set({
    'title': 'Future Nostalgia (UPC Edition)',
    'artistId': artistRef,
    'coverURL': 'https://placehold.co/200?text=Album+Nostalgia',
    'genre': ['Pop', 'Disco'],
    'type': 'album',
    'isPublic': true,
    'label': 'UPC Records',
    'stats': {
      'totalTracks': 2, // S'actualitzarà després
      'totalDuration': 0, // S'actualitzarà després
      'playCount': 500,
      'saves': 50,
    },
    'createdAt': now,
  });
  print('   - 1 Àlbum (Future Nostalgia) creat.');

  // --- 3. Crear Cançons de Prova i Afegir-les a l'Àlbum ---
  
  // Cançó 1
  final songId1 = 'song_dont_start';
  final songRef1 = _firestore.collection('songs').doc(songId1);
  const duration1 = 183;
  await songRef1.set({
    'title': 'Don\'t Start Now (UPC)',
    'artistId': artistRef,
    'artistName': 'Dua UPC',
    'albumId': albumRef1,
    'duration': duration1,
    'fileURL': 'https://storage.firebase.com/song1.mp3',
    'coverURL': 'https://placehold.co/200?text=Song+1',
    'genre': ['Pop', 'Disco'],
    'isPublic': true,
    'lyrics': 'If you don\'t wanna see me dancing with somebody...',
    'stats': {'playCount': 100, 'likes': 50, 'shares': 5},
    'createdAt': now,
  });
  // Afegir a la subcol·lecció de l'àlbum
  await albumRef1.collection('songs').doc(songId1).set({
    'songRef': songRef1,
    'trackNumber': 1,
    'title': 'Don\'t Start Now (UPC)',
    'duration': duration1,
    'addedAt': now,
  });

  // Cançó 2
  final songId2 = 'song_levitating';
  final songRef2 = _firestore.collection('songs').doc(songId2);
  const duration2 = 203;
  await songRef2.set({
    'title': 'Levitating (UPC)',
    'artistId': artistRef,
    'artistName': 'Dua UPC',
    'albumId': albumRef1,
    'duration': duration2,
    'fileURL': 'https://storage.firebase.com/song2.mp3',
    'coverURL': 'https://placehold.co/200?text=Song+2',
    'genre': ['Pop', 'Funk'],
    'isPublic': true,
    'lyrics': 'You want me, I want you, baby...',
    'stats': {'playCount': 80, 'likes': 40, 'shares': 3},
    'createdAt': now,
  });
  // Afegir a la subcol·lecció de l'àlbum
  await albumRef1.collection('songs').doc(songId2).set({
    'songRef': songRef2,
    'trackNumber': 2,
    'title': 'Levitating (UPC)',
    'duration': duration2,
    'addedAt': now,
  });
  
  print('   - 2 Cançons creades i assignades a l\'àlbum.');
  
  // Actualitzar l'àlbum amb les estadístiques reals
  await albumRef1.update({
    'stats.totalTracks': 2,
    'stats.totalDuration': duration1 + duration2,
  });
  
  // --- 4. Crear Playlist de Prova ---
  final playlistId1 = 'playlist_test_user';
  final playlistRef1 = _firestore.collection('playlists').doc(playlistId1);
  await playlistRef1.set({
    'name': 'El meu Descobriment Semanal',
    'description': 'Llista de prova creada automàticament.',
    'ownerId': userRef, // Referència a l'usuari
    'coverURL': 'https://placehold.co/200?text=My+Playlist',
    'isPublic': true,
    'isCollaborative': false,
    'stats': {'songCount': 2, 'totalDuration': duration1 + duration2, 'followers': 1, 'plays': 0},
    'createdAt': now,
    'updatedAt': now,
  });
  
  // Afegir cançons a la subcol·lecció de la playlist
  await playlistRef1.collection('songs').doc(songId1).set({
    'songRef': songRef1,
    'position': 1,
    'title': 'Don\'t Start Now (UPC)',
    'artistName': 'Dua UPC',
    'duration': duration1,
    'coverURL': songRef1.get().then((doc) => doc.data()?['coverURL'] ?? ''), // Denormalitzar de la cançó
    'addedBy': userRef,
    'addedAt': now,
  });
  await playlistRef1.collection('songs').doc(songId2).set({
    'songRef': songRef2,
    'position': 2,
    'title': 'Levitating (UPC)',
    'artistName': 'Dua UPC',
    'duration': duration2,
    'coverURL': songRef2.get().then((doc) => doc.data()?['coverURL'] ?? ''), // Denormalitzar de la cançó
    'addedBy': userRef,
    'addedAt': now,
  });
  
  print('   - 1 Playlist creada i omplerta.');

  // --- 5. Associar Dades de Mostra a l'Usuari (Subcol·leccions) ---

  // 5.a. Playlists Pròpies (ownedPlaylists)
  await userRef.collection('ownedPlaylists').doc(playlistId1).set({
    'playlistRef': playlistRef1,
    'createdAt': now,
  });
  print('   - 1 Playlist pròpia (ownedPlaylists) associada.');
  
  // 5.b. Àlbums Guardats (savedAlbums) - (Per al teu GridView)
  await userRef.collection('savedAlbums').doc(albumId1).set({
    'albumRef': albumRef1,
    'savedAt': fixedDate.subtract(const Duration(days: 5)),
  });
  print('   - 1 Àlbum guardat (savedAlbums) associat.');
  
  // 5.c. Historial de Reproducció (playHistory) - (Per al teu HistoryList)
  await userRef.collection('playHistory').add({
      'songId': songRef1,
      'playedAt': fixedDate.subtract(const Duration(minutes: 10)),
      'playDuration': duration1,
      'completed': true,
  });
  await userRef.collection('playHistory').add({
      'songId': songRef2,
      'playedAt': fixedDate.subtract(const Duration(minutes: 5)),
      'playDuration': 50, // Només 50 segons reproduïts
      'completed': false,
  });
  print('   - 2 Entrades a l\'historial (playHistory) associades.');
  
  // 5.d. Altres estadístiques de l'usuari (actualitzar followers/following)
  await userRef.update({
    'stats.followers': 1,
    'stats.following': 0,
  });
  print('   - Estadístiques de l\'usuari actualitzades.');


  print('🎉 Dades de mostra creades amb èxit i conformes a la teva estructura per a $userId.');
}