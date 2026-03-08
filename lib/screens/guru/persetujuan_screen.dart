// lib/screens/guru/persetujuan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

class PersetujuanScreen extends StatefulWidget {
  const PersetujuanScreen({super.key});

  @override
  State<PersetujuanScreen> createState() => _PersetujuanScreenState();
}

class _PersetujuanScreenState extends State<PersetujuanScreen> {
  // Fungsi Helper untuk format tanggal
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Fungsi untuk memanggil provider saat tombol ditekan
  void _handleApproval(TransactionModel trx, bool isApproved) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A4E69)),
      ),
    );

    // TODO: Ganti 'Guru_123' dengan UID asli dari Firebase Auth saat fitur login selesai
    bool success = await provider.prosesPersetujuan(
      trx,
      isApproved,
      'Guru_123',
    );

    // Tutup loading
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved ? 'Peminjaman disetujui!' : 'Peminjaman ditolak.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: isApproved ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Antrean Persetujuan',
          style: GoogleFonts.poppins(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.bell,
              color: Color(0xFF4A4E69),
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionProvider.streamPendingTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A4E69)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pendingList = snapshot.data ?? [];

          if (pendingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.mugHot,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada antrean ACC.',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  Text(
                    'Bapak/Ibu Guru bisa bersantai!',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pendingList.length,
            itemBuilder: (context, index) {
              return _buildApprovalCard(pendingList[index]);
            },
          );
        },
      ),
    );
  }

  // WIDGET CARD ACC: Modern & Clean
  Widget _buildApprovalCard(TransactionModel trx) {
    int durasi = trx.tglKembali.difference(trx.tglAmbil).inDays + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card (Nama Peminjam & Badge Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(
                          0xFF9A8C98,
                        ).withOpacity(0.3),
                        child: const Icon(
                          FontAwesomeIcons.userGraduate,
                          size: 14,
                          color: Color(0xFF4A4E69),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          trx.namaPeminjam,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF22223B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Menunggu',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF2E9E4)),
            ),

            // Info Alat & Tanggal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4E69).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.boxOpen,
                    color: Color(0xFF4A4E69),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trx.namaAlat,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(trx.tglAmbil)} - ${_formatDate(trx.tglKembali)} ($durasi Hari)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Teks Kegiatan
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          '"${trx.kegiatan}"',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Aksi (Tolak & Setujui)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleApproval(trx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Tolak',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApproval(trx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Setujui',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
