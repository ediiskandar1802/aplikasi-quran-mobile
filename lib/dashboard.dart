import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'surah_list_page.dart';
import 'profil_page.dart';
import 'doa_harian_page.dart';
import 'juz_page.dart';
import 'tafsir_page.dart';
import 'surah_detail_page.dart';
import 'pengaturan_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  Map<String, String> shalatTimes = {'Fajr': '04:40', 'Dhuhr': '11:50', 'Asr': '15:10', 'Maghrib': '17:58', 'Isha': '19:08'};
  String nextShalatName = 'Maghrib';
  String nextShalatTime = '17:58';
  String countdown = '-01:23:45';
  int halamanHariIni = 0;
  String lastSurah = '';
  int lastAyat = 0;
  int lastSurahNo = 2;
  String selectedBg = 'masjid_malam';
  String selectedWilayah = 'Kota Jakarta Selatan';
  Uint8List? customBgBytes;
  Timer? _countdownTimer;
  late List<Widget> _pages;

  // INI YANG BARU BOS - TANGGAL DINAMIS
  String tanggalMasehi = '';
  String tanggalHijriah = '';

  final List<Map<String, String>> bgOptions = [
    {'id': 'masjid_malam', 'name': 'Masjid Malam Bintang', 'url': 'https://images.unsplash.com/photo-1519810755548-39e2172d8d59?auto=format&fit=crop&w=800&q=80'},
    {'id': 'masjid_golden', 'name': 'Masjid Golden Hour', 'url': 'https://images.unsplash.com/photo-1542816417-098367c28d4f?auto=format&fit=crop&w=800&q=80'},
    {'id': 'kaaba', 'name': 'Ka\'bah', 'url': 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=800&q=80'},
    {'id': 'custom', 'name': 'Upload Foto Sendiri', 'url': 'custom'},
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _updateTanggal(); // SET TANGGAL HARI INI BOS
    });
    _loadAllData();
    _fetchShalatTime();
    _startCountdownTimer();
  }

  // FUNGSI BARU BIAR GAK SENIN TERUS BOS
  void _updateTanggal() {
    final now = DateTime.now();
    // Rabu, 1 Oktober 2026
    final masehi = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    setState(() {
      tanggalMasehi = masehi;
    });
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    try {
      final now = DateTime.now();
      final timesOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      DateTime? nextTime;
      String? nextName;
      for (var name in timesOrder) {
        final t = shalatTimes[name];
        if (t == null) continue;
        final parts = t.split(':');
        final dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
        if (dt.isAfter(now)) { nextTime = dt; nextName = name; break; }
      }
      if (nextTime == null) {
        final fajr = shalatTimes['Fajr']?? '04:40';
        final p = fajr.split(':');
        nextTime = DateTime(now.year, now.month, now.day + 1, int.parse(p[0]), int.parse(p[1]));
        nextName = 'Fajr';
      }
      if (nextTime!= null) {
        final diff = nextTime.difference(now);
        final h = diff.inHours.toString().padLeft(2, '0');
        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
        setState(() {
          countdown = '-$h:$m:$s';
          nextShalatName = nextName == 'Fajr'? 'Subuh' : nextName == 'Dhuhr'? 'Dzuhur' : nextName == 'Asr'? 'Asar' : nextName == 'Maghrib'? 'Maghrib' : 'Isya';
          nextShalatTime = '${nextTime!.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() { _countdownTimer?.cancel(); super.dispose(); }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReadJson = prefs.getString('last_read');
    final todayKey = 'ngaji_${DateTime.now().toIso8601String().split('T')[0]}';
    final hariIni = prefs.getInt(todayKey)?? 0;
    final bg = prefs.getString('selected_bg')?? 'masjid_malam';
    final wilayah = prefs.getString('selected_wilayah')?? 'Kota Jakarta Selatan';
    final customBgStr = prefs.getString('custom_bg_bytes');
    Uint8List? customBytes;
    if (customBgStr!= null) { try { customBytes = base64Decode(customBgStr); } catch (_) {} }
    if (mounted) {
      setState(() {
        halamanHariIni = hariIni;
        selectedBg = bg;
        selectedWilayah = wilayah;
        customBgBytes = customBytes;
        if (lastReadJson!= null) {
          final data = json.decode(lastReadJson);
          lastSurah = data['surahName']?? '';
          lastAyat = data['ayat']?? 0;
          lastSurahNo = data['surahNo']?? 2;
        }
        _buildPages();
      });
    }
  }

  void _buildPages() {
    _pages = [
      _HomeContent(
        shalatTimes: shalatTimes,
        nextShalatName: nextShalatName,
        nextShalatTime: nextShalatTime,
        countdown: countdown,
        selectedWilayah: selectedWilayah,
        halamanHariIni: halamanHariIni,
        lastSurah: lastSurah,
        lastAyat: lastAyat,
        lastSurahNo: lastSurahNo,
        selectedBg: selectedBg,
        bgOptions: bgOptions,
        customBgBytes: customBgBytes,
        onRefresh: _loadAllData,
        onLanjut: _onLanjutMembaca,
        onMenuTap: _onMenuTap,
        onChangeBg: _showBgPicker,
        tanggalMasehi: tanggalMasehi, // BAR
