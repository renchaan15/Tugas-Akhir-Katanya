// lib/models/item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String idDokumen;
  final String kodeInventaris;
  final String namaAlat;
  final String kategori;
  final String statusKetersediaan; // 'tersedia', 'dipinjam', 'maintenance'
  final String fotoAlatUrl;
  final List<String> bookedDates; // Format: "YYYY-MM-DD"

  ItemModel({
    required this.idDokumen,
    required this.kodeInventaris,
    required this.namaAlat,
    required this.kategori,
    required this.statusKetersediaan,
    required this.fotoAlatUrl,
    required this.bookedDates,
  });

  // Factory untuk mengonversi data dari Firestore (DocumentSnapshot) menjadi Object Dart
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      idDokumen: doc.id,
      kodeInventaris: data['kode_inventaris'] ?? '',
      namaAlat: data['nama_alat'] ?? 'Alat Tidak Diketahui',
      kategori: data['kategori'] ?? 'Lainnya',
      statusKetersediaan: data['status_ketersediaan'] ?? 'tersedia',
      fotoAlatUrl: data['foto_alat_url'] ?? '',
      bookedDates: List<String>.from(data['booked_dates'] ?? []),
    );
  }

  // Fungsi untuk mengonversi Object Dart kembali menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'kode_inventaris': kodeInventaris,
      'nama_alat': namaAlat,
      'kategori': kategori,
      'status_ketersediaan': statusKetersediaan,
      'foto_alat_url': fotoAlatUrl,
      'booked_dates': bookedDates,
    };
  }
}