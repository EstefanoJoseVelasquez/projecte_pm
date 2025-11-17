import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF121212),
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/img/logo.png'),
              ),
            ),
            Text(
              "SpotyUPC",
              style: TextStyle(
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
          // <--- AFEGIT
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GRID QUE S'AUTOADAPTA ---
              GridView.builder(
                itemCount: 8,
                shrinkWrap: true, // <--- IMPORTANT
                physics:
                    NeverScrollableScrollPhysics(), // <--- EVITA SCROLL DOBLE
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 8,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              "https://placehold.co/200",
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.grey.shade800,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Playlist ${index + 1}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 12),

              Text(
                "Torna a escoltar",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Novetats per a tu",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Les teves llistes",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
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
