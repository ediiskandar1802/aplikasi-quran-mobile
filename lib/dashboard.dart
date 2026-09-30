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

  final List<Map<String, String>> bgOptions = [
    {'id': 'masjid_malam', 'name': 'Masjid Malam Bintang', 'url': 'https://images.unsplash.com/photo-1519810755548-39e2172d8d59?auto=format&fit=crop&w=800&q=80'},
    {'id': 'masjid_golden', 'name': 'Masjid Golden Hour', 'url': 'https://images.unsplash.com/photo-1542816417-098367c28d4f?auto=format&fit=crop&w=800&q=80'},
    {'id': 'kaaba', 'name': 'Ka\'bah', 'url': 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?auto=format&fit=crop&w=800&q=80'},
    {'id': 'custom', 'name': 'Upload Foto Sendiri', 'url': 'custom'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _fetchShalatTime();
    _startCountdownTimer();
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
        final fajr = shalatTimes['Fajr'] ?? '04:40';
        final p = fajr.split(':');
        nextTime = DateTime(now.year, now.month, now.day + 1, int.parse(p[0]), int.parse(p[1]));
        nextName = 'Fajr';
      }
      if (nextTime != null) {
        final diff = nextTime.difference(now);
        final h = diff.inHours.toString().padLeft(2, '0');
        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
        setState(() {
          countdown = '-$h:$m:$s';
          nextShalatName = nextName == 'Fajr' ? 'Subuh' : nextName == 'Dhuhr' ? 'Dzuhur' : nextName == 'Asr' ? 'Asar' : nextName == 'Maghrib' ? 'Maghrib' : 'Isya';
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
    final hariIni = prefs.getInt(todayKey) ?? 0;
    final bg = prefs.getString('selected_bg') ?? 'masjid_malam';
    final wilayah = prefs.getString('selected_wilayah') ?? 'Kota Jakarta Selatan';
    final customBgStr = prefs.getString('custom_bg_bytes');
    Uint8List? customBytes;
    if (customBgStr != null) { try { customBytes = base64Decode(customBgStr); } catch (_) {} }
    if (mounted) {
      setState(() {
        halamanHariIni = hariIni;
        selectedBg = bg;
        selectedWilayah = wilayah;
        customBgBytes = customBytes;
        if (lastReadJson != null) {
          final data = json.decode(lastReadJson);
          lastSurah = data['surahName'] ?? '';
          lastAyat = data['ayat'] ?? 0;
          lastSurahNo = data['surahNo'] ?? 2;
        }
        _buildPages();
      });
    }
  }

  void _buildPages() {
    _pages = [
      _HomeContent(shalatTimes: shalatTimes, nextShalatName: nextShalatName, nextShalatTime: nextShalatTime, countdown: countdown, selectedWilayah: selectedWilayah, halamanHariIni: halamanHariIni, lastSurah: lastSurah, lastAyat: lastAyat, lastSurahNo: lastSurahNo, selectedBg: selectedBg, bgOptions: bgOptions, customBgBytes: customBgBytes, onRefresh: _loadAllData, onLanjut: _onLanjutMembaca, onMenuTap: _onMenuTap, onChangeBg: _showBgPicker),
      const SurahListPage(),
      const _AudioPlaceholder(),
      const ProfilPage(),
    ];
  }

  Future<void> _fetchShalatTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wilayah = prefs.getString('selected_wilayah') ?? 'Jakarta';
      final city = wilayah.contains('Jakarta') ? 'Jakarta' : wilayah.split(',').first;
      final url = Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=$city&country=Indonesia&method=11');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data']['timings'];
        setState(() {
          shalatTimes = {'Fajr': data['Fajr'] ?? '04:40', 'Dhuhr': data['Dhuhr'] ?? '11:50', 'Asr': data['Asr'] ?? '15:10', 'Maghrib': data['Maghrib'] ?? '17:58', 'Isha': data['Isha'] ?? '19:08'};
          _updateCountdown();
          _buildPages();
        });
      }
    } catch (_) {}
  }

  void _onLanjutMembaca() {
    if (lastSurah.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada riwayat bacaan'))); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => SurahDetailPage(surahNumber: lastSurahNo, surahName: lastSurah, surahArab: '', initialAyat: lastAyat))).then((_) => _loadAllData());
  }

  void _onMenuTap(String label) {
    Widget? page;
    switch (label) {
      case 'Juz': page = const JuzPage(); break;
      case 'Surah': setState(() => _selectedIndex = 1); return;
      case 'Tafsir': page = const TafsirPage(); break;
      case 'Doa Harian': page = const DoaHarianPage(); break;
      case 'Audio': setState(() => _selectedIndex = 2); return;
      case 'Pengaturan': page = const PengaturanPage(); break;
    }
    if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page!)).then((_) { _loadAllData(); _fetchShalatTime(); });
  }

  Future<void> _pickCustomBackground() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (file != null) {
        final bytes = await file.readAsBytes();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_bg_bytes', base64Encode(bytes));
        await prefs.setString('selected_bg', 'custom');
        setState(() { customBgBytes = bytes; selectedBg = 'custom'; });
        _loadAllData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Background custom berhasil diupload!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
    }
  }

  void _showBgPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children:[
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Text('Pilih Background Favorit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...bgOptions.map((bg) => ListTile(
            leading: Container(width: 50, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: bg['id'] == 'custom' ? const Color(0xFF0D2A54) : null, image: bg['id'] == 'custom' ? null : DecorationImage(image: NetworkImage(bg['url']!), fit: BoxFit.cover)), child: bg['id'] == 'custom' ? const Icon(Icons.upload, color: Colors.white, size: 18) : null),
            title: Text(bg['name']!, style: const TextStyle(fontSize: 13)),
            trailing: selectedBg == bg['id'] ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37)) : null,
            onTap: () async {
              if (bg['id'] == 'custom') { Navigator.pop(context); _pickCustomBackground(); }
              else { final prefs = await SharedPreferences.getInstance(); await prefs.setString('selected_bg', bg['id']!); setState(() => selectedBg = bg['id']!); Navigator.pop(context); _loadAllData(); }
            },
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); _pickCustomBackground(); }, icon: const Icon(Icons.photo_library, size: 18, color: Colors.white), label: const Text('Upload Background dari Galeri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2A54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) _buildPages();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D2A54),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Al-Qur\'an'),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic_outlined), label: 'Audio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final Map<String, String> shalatTimes; final String nextShalatName; final String nextShalatTime; final String countdown; final String selectedWilayah; final int halamanHariIni; final String lastSurah; final int lastAyat; final int lastSurahNo; final String selectedBg; final List<Map<String, String>> bgOptions; final Uint8List? customBgBytes; final VoidCallback onRefresh; final VoidCallback onLanjut; final Function(String) onMenuTap; final VoidCallback onChangeBg;
  const _HomeContent({required this.shalatTimes, required this.nextShalatName, required this.nextShalatTime, required this.countdown, required this.selectedWilayah, required this.halamanHariIni, required this.lastSurah, required this.lastAyat, required this.lastSurahNo, required this.selectedBg, required this.bgOptions, this.customBgBytes, required this.onRefresh, required this.onLanjut, required this.onMenuTap, required this.onChangeBg});

  @override
  Widget build(BuildContext context) {
    final isCustom = selectedBg == 'custom' && customBgBytes != null;
    final bgUrl = bgOptions.firstWhere((e) => e['id'] == selectedBg, orElse: () => bgOptions[0])['url']!;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        child: Column(children:[
          Container(
            height: 300, width: double.infinity,
            decoration: BoxDecoration(color: Colors.black, image: isCustom ? DecorationImage(image: MemoryImage(customBgBytes!), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)) : DecorationImage(image: NetworkImage(bgUrl), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken))),
            child: Stack(children:[
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.65)]))),
              SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Icon(Icons.menu, color: Colors.white, size: 24), Row(children:[InkWell(onTap: onChangeBg, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3))), child: const Icon(Icons.wallpaper, color: Colors.white, size: 18))), const SizedBox(width: 10), Stack(children:[const Icon(Icons.notifications_none, color: Colors.white, size: 24), Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)))])])]),
                const SizedBox(height: 20),
                Text('Senin, 16 Rabiul Tsani 1448 H', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                const SizedBox(height: 12),
                Row(children:[_shalatItem(nextShalatName, nextShalatTime, countdown, isNext: true), const SizedBox(width: 16), Container(width: 1, height: 40, color: Colors.white24), const SizedBox(width: 16), _shalatItem('Maghrib', shalatTimes['Maghrib'] ?? '17:58', ''), const SizedBox(width: 16), Container(width: 1, height: 40, color: Colors.white24), const SizedBox(width: 16), _shalatItem('Isya', shalatTimes['Isha'] ?? '19:08', ''), const Spacer()]),
                const SizedBox(height: 8),
                Row(children:[const Icon(Icons.location_on_outlined, color: Colors.white70, size: 12), const SizedBox(width: 4), Expanded(child: Text(selectedWilayah, style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis))]),
                const Spacer(),
                Text('$halamanHariIni halaman ngaji hari ini', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ]))),
            ]),
          ),
          Transform.translate(
            offset: const Offset(0, -35),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Column(children:[
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)]), child: Row(children:[Container(width: 60, height: 80, decoration: BoxDecoration(color: const Color(0xFFE91E63), borderRadius: BorderRadius.circular(8)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(Icons.menu_book, color: Colors.white, size: 30), SizedBox(height: 4), Text('AL QURAN', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))])), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[const Text('Pekan ini kamu\ntelah ngaji', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2)), const SizedBox(height: 6), Row(crossAxisAlignment: CrossAxisAlignment.end, children:[Text('$halamanHariIni', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D2A54))), const SizedBox(width: 6), const Text('Halaman', style: TextStyle(fontSize: 12, color: Colors.grey))])])), Column(children:[Row(children: List.generate(7, (i){final isToday=i==6; final h=(i==6?22.0:(i%3+1)*6.0); return Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 12, height: h, decoration: BoxDecoration(color: isToday? const Color(0xFFE91E63):Colors.grey.shade300, borderRadius: BorderRadius.circular(3)));})), const SizedBox(height: 4), const Text('A S S R K J S', style: TextStyle(fontSize: 9, letterSpacing: 2, color: Colors.grey))])])),
              const SizedBox(height: 12),
              InkWell(onTap: onLanjut, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]), child: Row(children:[Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0D2A54), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book, color: Color(0xFFD4AF37), size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[const Text('Lanjut Membaca', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 2), Text(lastSurah.isEmpty?'Belum ada riwayat - Buka surah apapun':'$lastSurah • Ayat $lastAyat', style: const TextStyle(color: Colors.grey, fontSize: 12))])), const Icon(Icons.chevron_right, color: Colors.grey, size: 20)]))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(onPressed: ()=>onMenuTap('Surah'), icon: const Icon(Icons.menu_book, color: Colors.white, size: 18), label: const Text('Baca Al-Qur\'an', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), elevation: 0))),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
                children: [
                  _customIconItem('Juz', 'assets/icons/icon_juz.png', onMenuTap),
                  _customIconItem('Surah', 'assets/icons/icon_surah.png', onMenuTap),
                  _customIconItem('Tafsir', 'assets/icons/icon_tafsir.png', onMenuTap),
                  _customIconItem('Doa Harian', 'assets/icons/icon_doa.png', onMenuTap),
                  _customIconItem('Audio', 'assets/icons/icon_audio.png', onMenuTap),
                  _customIconItem('Pengaturan', 'assets/icons/icon_pengaturan.png', onMenuTap),
                ],
              ),
            ])),
          ),
        ]),
      ),
    );
  }

  Widget _shalatItem(String name, String time, String countdown, {bool isNext=false}){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Row(children:[Text(name, style: TextStyle(color: isNext?const Color(0xFFD4AF37):Colors.white70, fontSize: 11, fontWeight: isNext?FontWeight.bold:FontWeight.normal)), if(isNext) Container(margin: const EdgeInsets.only(left:4), padding: const EdgeInsets.symmetric(horizontal:4, vertical:1), decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4)), child: const Text('NEXT', style: TextStyle(fontSize:7, color:Colors.white, fontWeight:FontWeight.bold)))]), Text(time, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows:[Shadow(color:Colors.black45, blurRadius:4)])), if(countdown.isNotEmpty) Text(countdown, style: TextStyle(color: isNext?const Color(0xFFD4AF37):Colors.white60, fontSize: 9, fontWeight: isNext?FontWeight.bold:FontWeight.normal))]);
  }

  static Widget _customIconItem(String label, String assetPath, Function(String) onTap){
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 2.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0,3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              width: 62, height: 62,
              decoration: const BoxDecoration(color: Color(0xFFFEFBEF), shape: BoxShape.circle),
              padding: const EdgeInsets.all(8),
              child: Image.asset(assetPath, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.menu_book, color: Color(0xFF0D2A54), size: 32)),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D2A54))),
          ],
        ),
      ),
    );
  }
}

class _AudioPlaceholder extends StatelessWidget{ const _AudioPlaceholder(); @override Widget build(BuildContext context){ return const Scaffold(body: Center(child: Text('Audio - Coming Soon'))); } }
