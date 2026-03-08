// lib/screens/guru/guru_main_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../siswa/katalog_screen.dart'; // Guru juga bisa lihat katalog
import 'persetujuan_screen.dart';
import '../shared/profil_screen.dart';

class GuruMainScreen extends StatefulWidget {
  const GuruMainScreen({super.key});

  @override
  State<GuruMainScreen> createState() => _GuruMainScreenState();
}

class _GuruMainScreenState extends State<GuruMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const KatalogScreen(), 
    const PersetujuanScreen(), // Antrean ACC
    const ProfilScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF4A4E69).withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 15,
          destinations: const [
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.house, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.house, color: Color(0xFF4A4E69)),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.checkToSlot, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.checkToSlot, color: Color(0xFF4A4E69)),
              label: 'Persetujuan',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.userTie, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.userTie, color: Color(0xFF4A4E69)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}