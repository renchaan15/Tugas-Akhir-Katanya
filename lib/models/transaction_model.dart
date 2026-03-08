// lib/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String idDokumen;
  final String itemId;
  final String namaAlat;
  final String userId;
  final String namaPeminjam;
  final DateTime tglAmbil;
  final DateTime tglKembali;
  final String kegiatan;
  final String guruAccId;
  final String statusPinjam; // 'menunggu_acc', 'disetujui', 'aktif_dipinjam', 'selesai', 'ditolak'
// --- TAMBAHKAN 4 VARIABEL INI ---
  final String kondisiSebelum;
  final String fotoSebelumUrl;
  final String kondisiSesudah;
  final String fotoSesudahUrl;

  TransactionModel({
    required this.idDokumen,
    required this.itemId,
    required this.namaAlat,
    required this.userId,
    required this.namaPeminjam,
    required this.tglAmbil,
    required this.tglKembali,
    required this.kegiatan,
    required this.guruAccId,
    required this.statusPinjam,

    this.kondisiSebelum = '',
    this.fotoSebelumUrl = '',
    this.kondisiSesudah = '',
    this.fotoSesudahUrl = '',
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      idDokumen: doc.id,
      itemId: data['item_id'] ?? '',
      namaAlat: data['nama_alat'] ?? '',
      userId: data['user_id'] ?? '',
      namaPeminjam: data['nama_peminjam'] ?? '',
      // Firestore menyimpan waktu dalam bentuk Timestamp, kita konversi ke DateTime
      tglAmbil: (data['tgl_ambil'] as Timestamp).toDate(),
      tglKembali: (data['tgl_kembali'] as Timestamp).toDate(),
      kegiatan: data['kegiatan'] ?? '',
      guruAccId: data['guru_acc_id'] ?? '',
      statusPinjam: data['status_pinjam'] ?? 'menunggu_acc',
      kondisiSebelum: data['kondisi_sebelum'] ?? '',
      fotoSebelumUrl: data['foto_sebelum_url'] ?? '',
      kondisiSesudah: data['kondisi_sesudah'] ?? '',
      fotoSesudahUrl: data['foto_sesudah_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'nama_alat': namaAlat,
      'user_id': userId,
      'nama_peminjam': namaPeminjam,
      'tgl_ambil': Timestamp.fromDate(tglAmbil),
      'tgl_kembali': Timestamp.fromDate(tglKembali),
      'kegiatan': kegiatan,
      'guru_acc_id': guruAccId,
      'status_pinjam': statusPinjam,
      'kondisi_sebelum': kondisiSebelum,
      'foto_sebelum_url': fotoSebelumUrl,
      'kondisi_sesudah': kondisiSesudah,
      'foto_sesudah_url': fotoSesudahUrl,
    };
  }
}