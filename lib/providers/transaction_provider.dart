// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fungsi untuk mengirim form pengajuan ke Firestore
  Future<bool> ajukanPeminjaman(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Menyimpan data ke koleksi 'transactions'
      await _firestore.collection('transactions').add(transaction.toMap());

      _isLoading = false;
      notifyListeners();
      return true; // Berhasil
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error submit transaksi: $e');
      return false; // Gagal
    }
  }

  // Stream untuk membaca transaksi yang butuh ACC (Khusus Guru)
  Stream<List<TransactionModel>> get streamPendingTransactions {
    return _firestore
        .collection('transactions')
        .where('status_pinjam', isEqualTo: 'menunggu_acc')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Fungsi helper untuk mendapatkan daftar tanggal di antara dua rentang waktu
  List<String> _getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<String> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      DateTime date = startDate.add(Duration(days: i));
      // Format YYYY-MM-DD
      days.add(
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      );
    }
    return days;
  }

  // Fungsi untuk memproses ACC dari Guru
  Future<bool> prosesPersetujuan(
    TransactionModel trx,
    bool isApproved,
    String guruId,
  ) async {
    try {
      // Gunakan WriteBatch agar update transaksi & item berjalan bersamaan dan aman (atomic)
      WriteBatch batch = _firestore.batch();

      DocumentReference trxRef = _firestore
          .collection('transactions')
          .doc(trx.idDokumen);
      DocumentReference itemRef = _firestore
          .collection('items')
          .doc(trx.itemId);

      if (isApproved) {
        // 1. Ubah status transaksi
        batch.update(trxRef, {
          'status_pinjam': 'disetujui',
          'guru_acc_id': guruId,
        });

        // 2. Kunci tanggal di Item agar tidak bisa dibooking orang lain
        List<String> bookedDates = _getDaysInBetween(
          trx.tglAmbil,
          trx.tglKembali,
        );
        batch.update(itemRef, {
          'booked_dates': FieldValue.arrayUnion(bookedDates),
        });
      } else {
        // Jika ditolak, cukup ubah status transaksi
        batch.update(trxRef, {
          'status_pinjam': 'ditolak',
          'guru_acc_id': guruId,
        });
      }

      // --- MULAI KODE NOTIFIKASI OTOMATIS ---
      DocumentReference notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'user_id': trx.userId, // Dikirim ke NIM siswa peminjam
        'title': isApproved
            ? 'Peminjaman Disetujui! 🎉'
            : 'Peminjaman Ditolak 😔',
        'body':
            'Pengajuan peminjaman untuk alat ${trx.namaAlat} telah ${isApproved ? 'disetujui' : 'ditolak'} oleh Guru. Silakan cek status di menu Peminjaman.',
        'is_read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // --- AKHIR KODE NOTIFIKASI OTOMATIS ---

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error proses ACC: $e');
      return false;
    }
  }

  // Tambahkan fungsi ini di dalam class TransactionProvider:

  Future<String> prosesSerahTerimaQR(String itemId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cari transaksi milik user ini, untuk item ini, yang statusnya 'disetujui' atau 'aktif_dipinjam'
      QuerySnapshot query = await _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId)
          .where('item_id', isEqualTo: itemId)
          .where('status_pinjam', whereIn: ['disetujui', 'aktif_dipinjam'])
          .get();

      if (query.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Tidak ada transaksi valid untuk alat ini.';
      }

      // Ambil dokumen transaksi pertama yang cocok
      DocumentSnapshot doc = query.docs.first;
      String statusSekarang = doc['status_pinjam'];
      String docId = doc.id;

      String statusBaru = statusSekarang == 'disetujui'
          ? 'aktif_dipinjam'
          : 'selesai';

      // Update status ke Firestore
      await _firestore.collection('transactions').doc(docId).update({
        'status_pinjam': statusBaru,
      });

      _isLoading = false;
      notifyListeners();

      return statusBaru == 'aktif_dipinjam'
          ? 'Berhasil! Alat sekarang sedang Anda pinjam.'
          : 'Berhasil! Alat telah dikembalikan.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error QR Scan: $e');
      return 'Terjadi kesalahan sistem.';
    }
  }

  // Tambahkan fungsi ini di dalam class TransactionProvider

  Future<bool> updateKondisiAlat({
    required String trxId,
    required bool isAmbil, // true = saat ambil barang, false = saat kembali
    required String catatanKondisi,
    required String fotoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> dataUpdate = {};

      if (isAmbil) {
        dataUpdate['kondisi_sebelum'] = catatanKondisi;
        dataUpdate['foto_sebelum_url'] = fotoUrl;
        // Opsional: Langsung ubah status menjadi aktif jika mengisi form saat pengambilan
        dataUpdate['status_pinjam'] = 'aktif_dipinjam';
      } else {
        dataUpdate['kondisi_sesudah'] = catatanKondisi;
        dataUpdate['foto_sesudah_url'] = fotoUrl;
        // Opsional: Langsung ubah status menjadi selesai saat pengembalian
        dataUpdate['status_pinjam'] = 'selesai';
      }

      await _firestore.collection('transactions').doc(trxId).update(dataUpdate);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error update kondisi: $e');
      return false;
    }
  }
}
