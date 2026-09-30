import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quran_service.dart';

const Map<int, int> surahStartPage = {
  1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
  11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267, 17: 282, 18: 293, 19: 305, 20: 312,
  21: 322, 22: 332, 23: 342, 24: 350, 25: 359, 26: 367, 27: 377, 28: 385, 29: 396, 30: 404,
  31: 411, 32: 415, 33: 418, 34: 428, 35: 434, 36: 440, 37: 446, 38: 453, 39: 458, 40: 467,
  41: 477, 42: 483, 43: 489, 44: 496, 45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518,
  51: 520, 52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542, 59: 545, 60: 549,
  61: 551, 62: 553, 63: 554, 64: 556, 65: 558, 66: 560, 67: 562, 68: 564, 69: 566, 70: 568,
  71: 570, 72: 572, 73: 575, 74: 577, 75: 580, 76: 582, 77: 583, 78: 586, 79: 586, 80: 587,
  81: 587, 82: 587, 83: 587, 84: 589, 85: 590, 86: 591, 87: 591, 88: 592, 89: 593, 90: 594,
  91: 595, 92: 595, 93: 596, 94: 596, 95: 597, 96: 597, 97: 598, 98: 598, 99: 599, 100: 599,
  101: 600, 102: 600, 103: 601, 104: 601, 105: 601, 106: 602, 107: 602, 108: 602, 109: 603, 110: 603,
  111: 603, 112: 604, 113: 604, 114: 604,
};
int getSurahEndPage(int no) => no >= 114? 604 : (surahStartPage[no + 1]?? 604) - 1;

String toArabicNumber(int n) {
  const arabic = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
  return n.toString().split('').map((d) => arabic[int.parse(d)]).join();
}

class SurahDetailPage extends StatefulWidget {
  final int surahNumber; final String surahName; final String surahArab; final int? initialAyat;
  const SurahDetailPage({super.key, required this.surahNumber, required this.surahName, required this.surahArab, this.initialAyat});
  @override State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> ayatList = [];
  List<List<Map<String, dynamic>>> pages = [];
  bool isLoading = true; bool isFullMushaf = true;
  int currentHlm = 1; List<int> hlmList = [];
  Set<int> bookmarks = {};
  late PageController _pageController;

  @override void initState() {
    super.initState();
    _pageController = PageController();
    currentHlm = surahStartPage[widget.surahNumber]?? 1;
    _generateHlmList(); _loadData(); _loadBookmarks();
  }
  @override void dispose() { _pageController.dispose(); super.dispose(); }
  void _generateHlmList() {
    final s = surahStartPage[widget.surahNumber]?? 1; final e = getSurahEndPage(widget.surahNumber);
    hlmList = List.generate(e - s + 1, (i) => s + i);
  }
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bookmark_${widget.surahNumber}';
    setState(() => bookmarks = (prefs.getStringList(key)?? []).map((e) => int.parse(e)).toSet());
  }
  Future<void> _toggleBookmark(int ayatNo) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bookmark_${widget.surahNumber}';
    setState(() {
      if (bookmarks.contains(ayatNo)) bookmarks.remove(ayatNo);
      else bookmarks.add(ayatNo);
    });
    await prefs.setStringList(key, bookmarks.map((e) => e.toString()).toList());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(bookmarks.contains(ayatNo)? 'Bookmark QS ${widget.surahNumber}:$ayatNo disimpan' : 'Bookmark dihapus'), backgroundColor: const Color(0xFF0D2A54)));
  }
  Future<void> _loadData() async {
    try {
      final list = await QuranService.loadSurah(widget.surahNumber);
      if (!mounted) return;
      setState(() { ayatList = list; _createPages(list); isLoading = false; currentHlm = surahStartPage[widget.surahNumber]?? 1; });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pages.isNotEmpty && _pageController.hasClients) {
          _pageController.jumpToPage(pages.length - 1);
          if (widget.initialAyat!= null) _scrollToAyat(widget.initialAyat!);
        }
      });
    } catch (e) { if (mounted) setState(() => isLoading = false); }
  }
  void _createPages(List<Map<String, dynamic>> all) {
    final s = surahStartPage[widget.surahNumber]?? 1; final e = getSurahEndPage(widget.surahNumber); final total = e - s + 1;
    if (total <= 1 || all.length <= 5) { pages = [all]; return; }
    final per = (all.length / total).ceil(); pages = [];
    for (var i = 0; i < all.length; i += per) { pages.add(all.sublist(i, i + per > all.length? all.length : i + per)); }
  }
  void _scrollToAyat(int no) { for (int p = 0; p < pages.length; p++) { if (pages[p].any((a) => a['no'] == no)) { _pageController.jumpToPage(pages.length - 1 - p); setState(() => currentHlm = (surahStartPage[widget.surahNumber]?? 1) + p); return; } } }

  Widget _ayahNumber(int no, {bool isBookmarked = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: isBookmarked? const Color(0xFFD4AF37) : const Color(0xFFFFF8E1),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFB71C1C), width: 1.2),
      ),
      child: Center(child: Text(toArabicNumber(no), style: GoogleFonts.scheherazadeNew(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFB71C1C)))),
    );
  }

  @override Widget build(BuildContext context) {
    final startPage = surahStartPage[widget.surahNumber]?? 1;
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54), iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.surahNumber}. ${widget.surahName} - Hlm ${toArabicNumber(currentHlm)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(isFullMushaf? Icons.translate : Icons.menu_book, color: const Color(0xFFD4AF37)), onPressed: () => setState(() => isFullMushaf =!isFullMushaf))],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(46), child: Container(height: 46, color: const Color(0xFF0A1F3D), child: ListView.builder(scrollDirection: Axis.horizontal, reverse: true, padding: const EdgeInsets.symmetric(horizontal: 8), itemCount: hlmList.length, itemBuilder: (_, i) { final h = hlmList[i]; final act = h == currentHlm; return InkWell(onTap: () { final idx = h - startPage; final rtl = pages.length - 1 - idx; if (rtl >= 0 && rtl < pages.length) _pageController.animateToPage(rtl, duration: const Duration(milliseconds: 300), curve: Curves.ease); }, child: Container(margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 7), padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: act? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Center(child: Text('Hlm ${toArabicNumber(h)}', style: TextStyle(color: act? const Color(0xFF0D2A54) : Colors.white70, fontSize: 12, fontWeight: act? FontWeight.bold : FontWeight.normal))))); }))),
      ),
      body: isLoading? const Center(child: CircularProgressIndicator()) : PageView.builder(
        controller: _pageController, reverse: true,
        onPageChanged: (rtl) { final act = pages.length - 1 - rtl; setState(() => currentHlm = startPage + act); },
        itemCount: pages.length,
        itemBuilder: (context, rtl) {
          final act = pages.length - 1 - rtl; if (act < 0 || act >= pages.length) return const SizedBox(); final pageAyats = pages[act];
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEF7),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1.5),
            ),
            child: Column(children: [
              Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Juz ${((currentHlm / 20).ceil())}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), Text('${toArabicNumber(currentHlm)}', style: const TextStyle(fontWeight: FontWeight.bold)), Text('${widget.surahName}', style: const TextStyle(fontSize: 10))])),
              Expanded(child: isFullMushaf? SingleChildScrollView(padding: const EdgeInsets.all(12), child: Text.rich(TextSpan(children: [
                if (act == 0 && widget.surahNumber!= 1 && widget.surahNumber!= 9) TextSpan(text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n", style: GoogleFonts.scheherazadeNew(fontSize: 18, fontWeight: FontWeight.bold)),
                for (var ayat in pageAyats)...[
                  TextSpan(text: "${ayat['arab']} ", style: GoogleFonts.scheherazadeNew(fontSize: 24, height: 2.1, color: Colors.black)),
                  WidgetSpan(child: InkWell(onTap: () => _toggleBookmark(ayat['no']), child: _ayahNumber(ayat['no'], isBookmarked: bookmarks.contains(ayat['no'])))),
                  const TextSpan(text: " "),
                ]
              ]), textAlign: TextAlign.justify, textDirection: TextDirection.rtl)) : ListView.builder(padding: const EdgeInsets.all(10), itemCount: pageAyats.length, itemBuilder: (_, i) { final a = pageAyats[i]; final isBm = bookmarks.contains(a['no']); return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: isBm? const Color(0xFFD4AF37) : Colors.grey.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [Expanded(child: Text(a['arab']?? '', textAlign: TextAlign.right, style: GoogleFonts.scheherazadeNew(fontSize: 24, height: 1.8))), const SizedBox(width: 6), InkWell(onTap: () => _toggleBookmark(a['no']), child: _ayahNumber(a['no'], isBookmarked: isBm))]),
                const Divider(), Text(a['indo']?? '', style: GoogleFonts.inter(fontSize: 13)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('QS ${widget.surahNumber}:${a['no']}', style: const TextStyle(fontSize: 9, color: Colors.grey)), Icon(isBm? Icons.bookmark : Icons.bookmark_border, size: 18, color: const Color(0xFFD4AF37))]),
              ])); })),
              Container(padding: const EdgeInsets.symmetric(vertical: 4), color: const Color(0xFFFDF6E3), child: Center(child: Text('${toArabicNumber(currentHlm)}', style: GoogleFonts.scheherazadeNew(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0D2A54))))),
            ]),
          );
        },
      ),
    );
  }
}
