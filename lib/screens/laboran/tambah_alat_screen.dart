// lib/screens/laboran/tambah_alat_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/inventory_provider.dart';
import '../../models/item_model.dart';
import '../../services/cloudinary_service.dart';

class TambahAlatScreen extends StatefulWidget {
  const TambahAlatScreen({super.key});

  @override
  State<TambahAlatScreen> createState() => _TambahAlatScreenState();
}

class _TambahAlatScreenState extends State<TambahAlatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();
  
  String _kategoriTerpilih = 'Kamera';
  final List<String> _kategoriList = ['Kamera', 'Lensa', 'Lighting', 'Audio', 'Aksesoris', 'Lainnya'];
  
  bool _isLoading = false;
  File? _imageFile; // Menyimpan file gambar sementara

  // Fungsi untuk memilih gambar dari Galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // Kompresi ringan
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Modifikasi fungsi simpan agar melakukan upload gambar terlebih dahulu
  void _simpanAlat() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String fotoUrl = '';

      try {
        // 1. Upload Gambar ke Cloudinary (Jika Ada)
        if (_imageFile != null) {
          final uploadedUrl = await CloudinaryService.uploadImage(_imageFile!);
          if (uploadedUrl != null) {
            fotoUrl = uploadedUrl;
          } else {
            throw Exception('Gagal mengunggah gambar ke server');
          }
        }

        // 2. Simpan Data ke Firestore
        final newItem = ItemModel(
          idDokumen: '',
          kodeInventaris: _kodeController.text.trim(),
          namaAlat: _namaController.text.trim(),
          kategori: _kategoriTerpilih,
          statusKetersediaan: 'tersedia',
          fotoAlatUrl: fotoUrl, // Menggunakan URL dari Cloudinary
          bookedDates: [],
        );

        await Provider.of<InventoryProvider>(context, listen: false).addItem(newItem);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alat berhasil ditambahkan!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tambah Alat Baru', style: GoogleFonts.poppins(color: const Color(0xFF22223B), fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UI Pilih Gambar
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E9E4).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4A4E69).withOpacity(0.3),
                          width: 2,
                          // style: BorderStyle.solid // Idealnya pakai package dotted_border, tapi solid juga elegan
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.cloudArrowUp, size: 40, color: Color(0xFF4A4E69)),
                                const SizedBox(height: 12),
                                Text('Tap untuk unggah foto alat', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('Kode Inventaris (Contoh: CAM-001)'),
                TextFormField(
                  controller: _kodeController,
                  validator: (val) => val!.isEmpty ? 'Kode tidak boleh kosong' : null,
                  decoration: _inputStyle('Masukkan kode inventaris'),
                ),
                const SizedBox(height: 16),

                _buildLabel('Nama Alat (Contoh: Sony A7III)'),
                TextFormField(
                  controller: _namaController,
                  validator: (val) => val!.isEmpty ? 'Nama alat tidak boleh kosong' : null,
                  decoration: _inputStyle('Masukkan nama alat'),
                ),
                const SizedBox(height: 16),

                _buildLabel('Kategori'),
                DropdownButtonFormField<String>(
                  value: _kategoriTerpilih,
                  items: _kategoriList.map((kat) => DropdownMenuItem(value: kat, child: Text(kat, style: GoogleFonts.poppins()))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _kategoriTerpilih = val!;
                    });
                  },
                  decoration: _inputStyle('Pilih kategori'),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanAlat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22223B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Simpan Data & Foto', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF4A4E69))),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF2E9E4).withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}