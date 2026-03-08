// lib/screens/siswa/form_peminjaman_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/item_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final ItemModel item;
  final DateTime startDate;
  final DateTime endDate;

  const FormPeminjamanScreen({
    super.key,
    required this.item,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  // Karena fitur Login (Auth) belum disempurnakan, kita pasang data *dummy* yang relevan 
  // sebagai *placeholder* agar UI terasa nyata saat diuji coba.
  final TextEditingController _namaController = TextEditingController(text: 'Azfa Jovaren Syahlirian');
  final TextEditingController _nimController = TextEditingController(text: '23076060');
  final TextEditingController _kegiatanController = TextEditingController();

  void _submitForm() async {
    if (_kegiatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tujuan kegiatan harus diisi!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    // Membentuk objek transaksi baru
    final newTransaction = TransactionModel(
      idDokumen: '', // Akan di-generate otomatis oleh Firestore
      itemId: widget.item.idDokumen,
      namaAlat: widget.item.namaAlat,
      userId: _nimController.text, // Nanti diganti dengan UID dari Firebase Auth
      namaPeminjam: _namaController.text,
      tglAmbil: widget.startDate,
      tglKembali: widget.endDate,
      kegiatan: _kegiatanController.text.trim(),
      guruAccId: '', // Masih kosong karena menunggu ACC
      statusPinjam: 'menunggu_acc', 
    );

    final success = await transactionProvider.ajukanPeminjaman(newTransaction);

    if (success && mounted) {
      // Tampilkan dialog sukses dengan desain cantik
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                'Pengajuan Berhasil!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Menunggu persetujuan (ACC) dari Guru yang bertugas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Kembali ke Beranda Katalog
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4E69),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: Text('Kembali ke Beranda', style: GoogleFonts.poppins(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TransactionProvider>().isLoading;
    final int durasiHari = widget.endDate.difference(widget.startDate).inDays + 1;

    // Helper format tanggal sederhana
    String formatDate(DateTime date) {
      return "${date.day}/${date.month}/${date.year}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Konfirmasi Peminjaman',
          style: GoogleFonts.poppins(color: const Color(0xFF22223B), fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Ringkasan Alat
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E9E4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: widget.item.fotoAlatUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(widget.item.fotoAlatUrl, fit: BoxFit.cover),
                          )
                        : const Icon(FontAwesomeIcons.cameraRetro, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.namaAlat,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          widget.item.kodeInventaris,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Detail Tanggal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A4E69),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tgl Ambil', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Text(formatDate(widget.startDate), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const Icon(FontAwesomeIcons.arrowRightLong, color: Colors.white54),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tgl Kembali', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Text(formatDate(widget.endDate), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Durasi: $durasiHari Hari', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF22223B))),
            ),
            const SizedBox(height: 32),

            // Form Input
            Text('Data Peminjam', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF22223B))),
            const SizedBox(height: 12),
            TextField(
              controller: _namaController,
              enabled: false, // Siswa tidak boleh ubah nama sendiri
              style: GoogleFonts.poppins(color: Colors.grey[700]),
              decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(FontAwesomeIcons.userPen, size: 18)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kegiatanController,
              maxLines: 3,
              style: GoogleFonts.poppins(),
              decoration: const InputDecoration(
                hintText: 'Contoh: Syuting tugas akhir pembuatan iklan komersial kelompok 3...',
                labelText: 'Tujuan/Kegiatan',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22223B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Kirim Pengajuan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}