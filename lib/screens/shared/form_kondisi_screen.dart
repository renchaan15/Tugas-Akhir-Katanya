// lib/screens/shared/form_kondisi_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../services/cloudinary_service.dart';

class FormKondisiScreen extends StatefulWidget {
  final TransactionModel transaksi;
  final bool isAmbil; // true: Serah terima awal, false: Pengembalian

  const FormKondisiScreen({super.key, required this.transaksi, required this.isAmbil});

  @override
  State<FormKondisiScreen> createState() => _FormKondisiScreenState();
}

class _FormKondisiScreenState extends State<FormKondisiScreen> {
  // Toggle Status: Default asumsikan alat aman
  bool _isKondisiBaik = true; 

  final _catatanController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _submitLog() async {
    // 1. VALIDASI JIKA TOGGLE "ADA MASALAH" AKTIF
    if (!_isKondisiBaik) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wajib menyertakan foto bukti kerusakan/kendala!'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_catatanController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan kendala tidak boleh kosong!'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      String finalFotoUrl = '';
      String finalCatatan = 'Kondisi alat aman dan lengkap.'; // Default otomatis jika aman

      // 2. JIKA ADA MASALAH, UPLOAD FOTO TERLEBIH DAHULU
      if (!_isKondisiBaik) {
        final String? uploadedUrl = await CloudinaryService.uploadImage(_imageFile!);
        if (uploadedUrl == null) throw Exception('Gagal mengunggah gambar ke server.');
        
        finalFotoUrl = uploadedUrl;
        finalCatatan = _catatanController.text.trim();
      }

      // 3. SIMPAN KE FIRESTORE
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final success = await provider.updateKondisiAlat(
        trxId: widget.transaksi.idDokumen,
        isAmbil: widget.isAmbil,
        catatanKondisi: finalCatatan,
        fotoUrl: finalFotoUrl,
      );

      if (success && mounted) {
        Navigator.pop(context); // Kembali ke layar sebelumnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isAmbil ? 'Serah terima berhasil dicatat!' : 'Pengembalian selesai!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.isAmbil ? 'Serah Terima Alat' : 'Pengembalian Alat';

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: GoogleFonts.poppins(color: const Color(0xFF22223B), fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Alat Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.boxOpen, color: Color(0xFF4A4E69), size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.transaksi.namaAlat, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Peminjam: ${widget.transaksi.namaPeminjam}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Toggle Pilihan Kondisi
            Text('Bagaimana kondisi alat?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF4A4E69), fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isKondisiBaik = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isKondisiBaik ? Colors.green.shade50 : Colors.white,
                        border: Border.all(color: _isKondisiBaik ? Colors.green : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(FontAwesomeIcons.circleCheck, color: _isKondisiBaik ? Colors.green : Colors.grey, size: 24),
                          const SizedBox(height: 8),
                          Text('Aman & Baik', style: GoogleFonts.poppins(color: _isKondisiBaik ? Colors.green.shade700 : Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isKondisiBaik = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isKondisiBaik ? Colors.red.shade50 : Colors.white,
                        border: Border.all(color: !_isKondisiBaik ? Colors.redAccent : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(FontAwesomeIcons.triangleExclamation, color: !_isKondisiBaik ? Colors.redAccent : Colors.grey, size: 24),
                          const SizedBox(height: 8),
                          Text('Ada Masalah', style: GoogleFonts.poppins(color: !_isKondisiBaik ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tampilkan Form Hanya Jika "Ada Masalah" Terpilih
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity), // Kosong jika aman
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wajib Upload Foto Kendala', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF4A4E69))),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF9A8C98).withOpacity(0.5), width: 2),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.camera, size: 30, color: Color(0xFF4A4E69)),
                                const SizedBox(height: 12),
                                Text('Jepret Foto Titik Kerusakan', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Catatan Detail Kerusakan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF4A4E69))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Misal: Bodi kamera retak di bagian bawah, lensa kotor...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              crossFadeState: _isKondisiBaik ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 40),

            // Tombol Submit Dinamis
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isKondisiBaik ? const Color(0xFF4A4E69) : Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isKondisiBaik ? 'Selesaikan (Tanpa Catatan)' : 'Simpan Laporan & Selesaikan', 
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}