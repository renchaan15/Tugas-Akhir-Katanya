// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String? _userRole;
  String? _userName;
  String? _userNim;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get userNim => _userNim;
  bool get isLoading => _isLoading;

  // Fungsi Login
  Future<String> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Autentikasi dengan Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _currentUser = userCredential.user;

      // 2. Ambil data Role dari koleksi 'users' di Firestore berdasarkan UID
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists) {
        _userRole = userDoc['role'];
        _userName = userDoc['nama_lengkap'];
        _userNim = userDoc['nomor_induk'];
        
        _isLoading = false;
        notifyListeners();
        return 'success'; // Login berhasil
      } else {
        await _auth.signOut(); // Jika data tidak ada di Firestore, paksa logout
        _isLoading = false;
        notifyListeners();
        return 'Data pengguna tidak ditemukan di database.';
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        return 'Email tidak terdaftar.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Kata sandi salah.';
      }
      return 'Terjadi kesalahan: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Error sistem: $e';
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _userRole = null;
    _userName = null;
    _userNim = null;
    notifyListeners();
  }
}