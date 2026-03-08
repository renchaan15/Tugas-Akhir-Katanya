// lib/screens/shared/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/transaction_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // Mencegah scan berulang kali dalam 1 detik
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String scannedItemId = barcodes.first.rawValue!;
      
      setState(() => _isProcessing = true);
      cameraController.stop(); // Hentikan kamera sementara proses ke database

      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      final provider = Provider.of<TransactionProvider>(context, listen: false);
      // TODO: Ganti '23076060' dengan UID/NIM Siswa yang sedang login
      String resultMessage = await provider.prosesSerahTerimaQR(scannedItemId, '23076060');

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        
        // Tampilkan hasil dan kembali
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Hasil Scan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(resultMessage, style: GoogleFonts.poppins()),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke layar sebelumnya
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A4E69)),
                child: Text('OK', style: GoogleFonts.poppins(color: Colors.white)),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Scan QR Code Alat', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Overlay Scanner UI (Border di tengah layar)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Arahkan kamera ke QR Code di alat',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, backgroundColor: Colors.black45),
              ),
            ),
          )
        ],
      ),
    );
  }
}