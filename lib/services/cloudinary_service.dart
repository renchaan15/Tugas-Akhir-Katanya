// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // TODO: Ganti dengan Cloud Name dan Upload Preset dari dashboard Cloudinary kamu
  static const String cloudName = 'dzgqbxubr'; 
  static const String uploadPreset = 'rental_alat_preset';

  /// Mengunggah gambar ke Cloudinary dan mengembalikan URL resminya
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      // Membuat request multipart untuk mengirim file
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = utf8.decode(responseData);
        final jsonMap = jsonDecode(responseString);
        
        // Mengembalikan URL gambar yang sudah di-hosting
        return jsonMap['secure_url']; 
      } else {
        debugPrint('Gagal upload: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error upload ke Cloudinary: $e');
      return null;
    }
  }
}