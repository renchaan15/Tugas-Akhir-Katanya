// lib/screens/siswa/siswa_main_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'katalog_screen.dart';
import 'peminjaman_siswa_screen.dart';
import '../shared/profil_screen.dart';

class SiswaMainScreen extends StatefulWidget {
  const SiswaMainScreen({super.key});

  @override
  State<SiswaMainScreen> createState() => _SiswaMainScreenState();
}

class _SiswaMainScreenState extends State<SiswaMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const KatalogScreen(), // Indeks 0: Beranda/Katalog
    const PeminjamanSiswaScreen(), // Indeks 1: Aktif/Riwayat
    const ProfilScreen(), // Indeks 2: Profil & Notif
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
          shadowColor: Colors.black.withOpacity(0.5),
          destinations: const [
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.boxOpen, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.boxOpen, color: Color(0xFF4A4E69)),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.clipboardList, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.clipboardList, color: Color(0xFF4A4E69)),
              label: 'Peminjaman',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.userAstronaut, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.userAstronaut, color: Color(0xFF4A4E69)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}