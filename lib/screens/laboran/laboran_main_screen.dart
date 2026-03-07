// lib/screens/laboran/laboran_main_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dashboard_screen.dart';
import 'inventaris_screen.dart';
import 'transaksi_admin_screen.dart';

class LaboranMainScreen extends StatefulWidget {
  const LaboranMainScreen({super.key});

  @override
  State<LaboranMainScreen> createState() => _LaboranMainScreenState();
}

class _LaboranMainScreenState extends State<LaboranMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(), // Indeks 0: Statistik & Kalender
    const InventarisScreen(), // Indeks 1: CRUD Alat & QR
    const TransaksiAdminScreen(), // Indeks 2: Manajemen & Scan QR
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
          indicatorColor: const Color(0xFF9A8C98).withOpacity(0.3),
          labelTextStyle: MaterialStateProperty.all(
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
          elevation: 20,
          destinations: const [
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.chartPie, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.chartPie, color: Color(0xFF22223B)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.boxesStacked, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.boxesStacked, color: Color(0xFF22223B)),
              label: 'Inventaris',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.handshakeAngle, color: Colors.grey),
              selectedIcon: Icon(FontAwesomeIcons.handshakeAngle, color: Color(0xFF22223B)),
              label: 'Transaksi',
            ),
          ],
        ),
      ),
    );
  }
}