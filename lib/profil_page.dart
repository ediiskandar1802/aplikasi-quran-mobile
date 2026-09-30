import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'surah_detail_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int bookmarkCount = 0;
  int riwayatCount = 0;
  List<String> bookmarkList = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    final riwayat = prefs.getStringList('riwayat') ?? [];
    setState(() {
      bookmarkCount = bookmarks.length;
      riwayatCount = riwayat.length;
      bookmarkList = bookmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF0D2A54)),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: IslamicPatternPainter())),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2.5), color: Colors.white.withOpacity(0.1)),
                          child: const Icon(Icons.person, size: 45, color: Color(0xFFD4AF37)),
                        ),
                        const SizedBox(height: 12),
                        const Text('Assalamu\'alaikum', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Semoga Allah senantiasa\nmemberkahi langkah kita', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _menuItem(icon: Icons.access_time_filled, title: 'Riwayat Bacaan', subtitle: riwayatCount > 0 ? '$riwayatCount surah dibaca' : null, onTap: () {}),
                  _menuItem(
                    icon: Icons.bookmark,
                    title: 'Bookmark',
                    subtitle: bookmarkCount > 0 ? '$bookmarkCount ayat tersimpan - Tap untuk lanjut baca' : 'Belum ada bookmark',
                    badge: bookmarkCount,
                    onTap: () => _showBookmarkPage(),
                  ),
                  _menuItem(icon: Icons.menu_book, title: 'Tafsir Tersimpan', onTap: () {}),
                  _menuItem(icon: Icons.settings, title: 'Pengaturan', onTap: () {}),
                  _menuItem(icon: Icons.info, title: 'Tentang Aplikasi', onTap: () => showAboutDialog(context: context, applicationName: 'Al-Qur\'an App', applicationVersion: '1.0.0')),
                  const SizedBox(height: 20),
                  Center(child: Column(children: [Text('Al-Qur\'an App v1.0.0', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)), Text('100% Offline • Biru Gold Theme', style: TextStyle(fontSize: 10, color: Colors.grey.shade400))])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String title, String? subtitle, int? badge, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0D2A54), size: 22),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0D2A54))), if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])),
            if (badge != null && badge > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10)), child: Text('$badge', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _showBookmarkPage() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bookmark Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(onPressed: () async { await prefs.remove('bookmarks'); setState(() { bookmarkCount = 0; bookmarkList = []; }); if (mounted) Navigator.pop(context); }, child: const Text('Hapus Semua', style: TextStyle(color: Colors.red, fontSize: 12))),
                ],
              ),
            ),
            Expanded(
              child: bookmarks.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bookmark_border, size: 60, color: Colors.grey.shade300), const SizedBox(height: 12), Text('Belum ada bookmark', style: TextStyle(color: Colors.grey.shade500))]))
                  : ListView.builder(
                      controller: controller,
                      itemCount: bookmarks.length,
                      itemBuilder: (_, i) {
                        final parts = bookmarks[i].split(':');
                        final surahNo = int.tryParse(parts[0]) ?? 1;
                        final ayatNo = int.tryParse(parts[1]) ?? 1;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF8F6F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                          child: ListTile(
                            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0D2A54), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(parts[0], style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)))),
                            title: Text('QS $surahNo : Ayat $ayatNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D2A54))),
                            subtitle: Text('Tap untuk melanjutkan bacaan', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(12)), child: const Text('Lanjut', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                            onTap: () {
                              Navigator.pop(context); // tutup bottom sheet
                              // BUKA SURAH DETAIL DAN LANGSUNG SCROLL KE AYAT YANG DIBOOKMARK!
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SurahDetailPage(
                                    surahNumber: surahNo,
                                    surahName: 'Surah $surahNo',
                                    surahArab: 'سورة $surahNo',
                                    initialAyat: ayatNo, // <-- ini yang bikin langsung lanjut ke ayat bookmark!
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ).then((_) => _loadStats()); // reload setelah tutup
  }
}

class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.08)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawArc(Rect.fromLTWH(-30, -30, 100, 100), 0, 3.14, false, paint);
    canvas.drawArc(Rect.fromLTWH(-20, -20, 80, 80), 0, 3.14, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - 70, -30, 100, 100), 0, 3.14, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - 60, -20, 80, 80), 0, 3.14, false, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
