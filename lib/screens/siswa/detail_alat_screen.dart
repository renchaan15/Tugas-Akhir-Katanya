// lib/screens/siswa/detail_alat_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/item_model.dart';
import 'form_peminjaman_screen.dart';

class DetailAlatScreen extends StatefulWidget {
  final ItemModel item;

  const DetailAlatScreen({super.key, required this.item});

  @override
  State<DetailAlatScreen> createState() => _DetailAlatScreenState();
}

class _DetailAlatScreenState extends State<DetailAlatScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  // Fungsi untuk mengecek apakah tanggal tertentu sudah di-booking
  bool _isDateBooked(DateTime day) {
    // Format DateTime ke YYYY-MM-DD
    String formattedDate =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return widget.item.bookedDates.contains(formattedDate);
  }

  // Fungsi validasi: Mencegah user memblok rentang hari yang melewati hari yang sudah di-booking
  bool _isRangeValid(DateTime? start, DateTime? end) {
    if (start == null || end == null) return true;
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      DateTime currentDay = start.add(Duration(days: i));
      if (_isDateBooked(currentDay)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Gambar Alat di Latar Belakang Atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: widget.item.fotoAlatUrl.isNotEmpty
                ? Image.network(widget.item.fotoAlatUrl, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFFF2E9E4),
                    child: const Icon(
                      FontAwesomeIcons.cameraRetro,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
          ),

          // Tombol Back Custom
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF22223B),
                ),
              ),
            ),
          ),

          // 2. Konten Detail (Melengkung ke atas)
          Positioned(
            top: size.height * 0.4,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Informasi Alat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4A4E69,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.item.kategori,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4A4E69),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.item.namaAlat,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kode Inventaris: ${widget.item.kodeInventaris}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider(
                      height: 40,
                      thickness: 1,
                      color: Color(0xFFF2E9E4),
                    ),

                    // Kalender Peminjaman
                    Text(
                      'Pilih Tanggal Peminjaman',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Container Kalender yang Cantik
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF2E9E4),
                          width: 2,
                        ),
                      ),
                      child: TableCalendar(
                        firstDay:
                            DateTime.now(), // Tidak bisa pinjam di masa lalu
                        lastDay: DateTime.now().add(
                          const Duration(days: 60),
                        ), // Max 2 bulan ke depan
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_rangeStart, day) ||
                            isSameDay(_rangeEnd, day),
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        rangeSelectionMode: _rangeSelectionMode,

                        // LOGIKA PENTING: Mendisable tanggal yang sudah dibooking
                        enabledDayPredicate: (day) {
                          return !_isDateBooked(day);
                        },

                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_rangeStart, selectedDay)) {
                            setState(() {
                              _rangeStart = selectedDay;
                              _rangeEnd =
                                  null; // Reset end date jika mulai ulang
                              _focusedDay = focusedDay;
                              _rangeSelectionMode =
                                  RangeSelectionMode.toggledOff;
                            });
                          }
                        },
                        onRangeSelected: (start, end, focusedDay) {
                          // Validasi rentang tanggal
                          if (!_isRangeValid(start, end)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'Terdapat tanggal yang sudah dibooking di antara rentang tersebut!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            );
                            setState(() {
                              _rangeStart = null;
                              _rangeEnd = null;
                            });
                            return;
                          }

                          setState(() {
                            _rangeStart = start;
                            _rangeEnd = end;
                            _focusedDay = focusedDay;
                            _rangeSelectionMode = RangeSelectionMode.toggledOn;
                          });
                        },

                        // Kustomisasi UI Kalender
                        calendarStyle: CalendarStyle(
                          rangeHighlightColor: const Color(
                            0xFF9A8C98,
                          ).withOpacity(0.3),
                          rangeStartDecoration: const BoxDecoration(
                            color: Color(0xFF4A4E69),
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: const BoxDecoration(
                            color: Color(0xFF4A4E69),
                            shape: BoxShape.circle,
                          ),
                          disabledTextStyle: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                          disabledDecoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ), // Spasi agar tidak tertutup tombol bawah
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button Custom di Bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_rangeStart != null)
                ? () {
                    // Jika end date kosong (pinjam 1 hari), samakan dengan start date
                    DateTime end = _rangeEnd ?? _rangeStart!;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormPeminjamanScreen(
                          item: widget.item,
                          startDate: _rangeStart!,
                          endDate: end,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22223B),
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: Text(
              _rangeStart != null && _rangeEnd != null
                  ? 'Ajukan Peminjaman (${_rangeEnd!.difference(_rangeStart!).inDays + 1} Hari)'
                  : _rangeStart != null
                  ? 'Ajukan Peminjaman (1 Hari)'
                  : 'Pilih Tanggal Dulu',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
