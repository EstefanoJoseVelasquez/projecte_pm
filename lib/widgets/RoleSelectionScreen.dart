import 'package:flutter/material.dart';
import 'package:projecte_pm/models/artist/artist.dart';
import 'package:projecte_pm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class RoleSelectionScreen extends StatefulWidget {
  final FirebaseAuth.User user;

  const RoleSelectionScreen({required this.user, super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isArtist = false;
  bool _isLoading = false;

  Future<void> _finalizeRegistration() async {
    // 1. Iniciar estat de càrrega
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Obtenir el nom d'usuari
      // Utilitza displayName si existeix (com amb Google Sign-In), sinó la part de l'email abans de l'@.
      final String name =
          widget.user.displayName ?? widget.user.email!.split('@').first;

      // 3. Cridar la funció de creació de perfil a Firestore
      // Això crea el document a /users/{uid} o /artists/{uid}
      await createUserOrArtistProfile(widget.user, _isArtist, name);

      // 4. Tornar enrere (tancar aquesta pantalla i mostrar LandingPage)
      // Això només s'executa si la crida anterior a Firestore ha tingut èxit.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // 5. Gestió d'errors
      print('Error finalitzant el registre/selecció de rol: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: No s\'ha pogut crear el perfil. Torna a intentar-ho.',
          ),
        ),
      );
    } finally {
      // 6. Finalitzar estat de càrrega
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa el teu Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Estàs a punt de començar. Com vols utilitzar MusicApp?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // --- CHECKBOX PER A ARTISTA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isArtist,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isArtist = newValue ?? false;
                    });
                  },
                ),
                Text('Sóc **Artista** (Vull pujar música)'),
              ],
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _finalizeRegistration,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      _isArtist
                          ? 'Continuar com a Artista'
                          : 'Continuar com a Usuari',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
