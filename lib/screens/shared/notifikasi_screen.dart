// lib/screens/shared/notifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  // Fungsi format waktu sederhana (Bisa dipercanggih pakai package 'timeago' nanti)
  String _formatTime(DateTime date) {
    return "${date.day}/${date.month} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    // TODO: Ganti '23076060' dengan UID/NIM user yang sedang login
    final currentUserNim = '23076060'; 

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notifikasi', style: GoogleFonts.poppins(color: const Color(0xFF22223B), fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notifProvider.streamUserNotifications(currentUserNim),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A4E69)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan data.'));
          }

          final notifikasiList = snapshot.data ?? [];

          if (notifikasiList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.bellSlash, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Belum ada notifikasi.', style: GoogleFonts.poppins(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notifikasiList.length,
            itemBuilder: (context, index) {
              final notif = notifikasiList[index];
              return _buildNotifCard(context, notifProvider, notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotifCard(BuildContext context, NotificationProvider provider, NotificationModel notif) {
    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          provider.tandaiSudahDibaca(notif.id);
        }
        // TODO: Bisa tambahkan navigasi ke halaman detail peminjaman jika dibutuhkan
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : Colors.blue.shade50, // Pembeda warna
          borderRadius: BorderRadius.circular(16),
          border: notif.isRead ? null : Border.all(color: Colors.blue.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead ? const Color(0xFFF2E9E4) : Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notif.title.contains('Disetujui') ? FontAwesomeIcons.check : 
                notif.title.contains('Ditolak') ? FontAwesomeIcons.xmark : FontAwesomeIcons.bell,
                color: notif.isRead ? Colors.grey : const Color(0xFF4A4E69),
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.poppins(fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 14, color: const Color(0xFF22223B)),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.body, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Text(_formatTime(notif.timestamp), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}