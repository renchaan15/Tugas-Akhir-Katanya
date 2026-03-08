// lib/providers/inventory_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class InventoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendapatkan daftar alat secara realtime dari koleksi 'items'
  Stream<List<ItemModel>> get streamItems {
    return _firestore.collection('items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    });
  }

  // Fungsi untuk Laboran: Menambah alat baru ke Firestore
  Future<void> addItem(ItemModel item) async {
    try {
      await _firestore.collection('items').add(item.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint("Error menambahkan item: $e");
      rethrow;
    }
  }

  // Fungsi untuk Laboran: Menghapus alat
  Future<void> deleteItem(String idDokumen) async {
    try {
      await _firestore.collection('items').doc(idDokumen).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("Error menghapus item: $e");
      rethrow;
    }
  }
}