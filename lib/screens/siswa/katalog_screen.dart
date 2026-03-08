// lib/screens/siswa/katalog_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/inventory_provider.dart';
import '../../models/item_model.dart';
import 'detail_alat_screen.dart';
import '../shared/notifikasi_screen.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Kamera',
    'Lensa',
    'Lighting',
    'Audio',
    'Aksesoris',
  ];

  @override
  Widget build(BuildContext context) {
    // Memanggil provider untuk mendapatkan stream data
    final inventoryProvider = Provider.of<InventoryProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFF2E9E4,
      ), // Warna background pastel modern
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategories(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<ItemModel>>(
                stream: inventoryProvider.streamItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A4E69),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Terjadi kesalahan: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];

                  // Filter berdasarkan kategori
                  final filteredItems = _selectedCategory == 'Semua'
                      ? items
                      : items
                            .where((item) => item.kategori == _selectedCategory)
                            .toList();

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FontAwesomeIcons.boxOpen,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada alat di kategori ini',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              0.75, // Mengatur proporsi tinggi & lebar card
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildGlassCard(filteredItems[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// WIDGET HEADER: Salam, Notifikasi & Profil
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Teks Salam
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Siswa!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Mau pinjam apa hari ini?',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Tombol Notifikasi (Lonceng)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(FontAwesomeIcons.bell, color: Color(0xFF4A4E69), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar Profil
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF9A8C98).withOpacity(0.3),
            child: const Icon(FontAwesomeIcons.userAstronaut, color: Color(0xFF4A4E69)),
          ),
        ],
      ),
    );
  }

  // WIDGET SEARCH BAR: Elegan & Clean
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Cari kamera, lensa, tripod...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Colors.grey,
              size: 18,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: false,
          ),
        ),
      ),
    );
  }

  // WIDGET KATEGORI: Horizontal Scroll
  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = _categories[index];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A4E69) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A4E69)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // WIDGET CARD ITEM: Glassmorphism Effect
  Widget _buildGlassCard(ItemModel item) {
    // Menentukan warna badge status
    Color statusColor = item.statusKetersediaan == 'tersedia'
        ? Colors.green.shade400
        : item.statusKetersediaan == 'dipinjam'
        ? Colors.orange.shade400
        : Colors.red.shade400;

    return GestureDetector(
      onTap: () {
        // Navigasi dengan animasi bawaan Material
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailAlatScreen(item: item)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Alat (Menggunakan NetworkImage atau Placeholder)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: item.fotoAlatUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: Image.network(
                              item.fotoAlatUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    FontAwesomeIcons.camera,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                            ),
                          )
                        : const Icon(
                            FontAwesomeIcons.camera,
                            color: Colors.grey,
                            size: 40,
                          ),
                  ),
                ),
                // Informasi Alat
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaAlat,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF22223B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.kategori,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Badge Status Ketersediaan
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.statusKetersediaan.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
