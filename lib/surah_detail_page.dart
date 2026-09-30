import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'data/quran_offline_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

int getSurahEndPage(int no) {
  if (no >= 114) return 604;
  return (surahStartPage[no + 1] ?? 604) - 1;
}

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String surahArab;
  final int? initialAyat;
  const SurahDetailPage({super.key, required this.surahNumber, required this.surahName, required this.surahArab, this.initialAyat});
  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> ayatList = [];
  List<List<Map<String, dynamic>>> pages = [];
  bool isLoading = true;
  bool isFullMushaf = true;
  Set<String> bookmarkedAyats = {};
  double fontSize = 30;
  int currentHlm = 1;
  List<int> hlmList = [];
  final PageController _pageController = PageController();
  Timer? _readTimer;
  int _secondsOnPage = 0;

  @override
  void initState() {
    super.initState();
    currentHlm = surahStartPage[widget.surahNumber] ?? 1;
    _generateHlmList();
    _loadBookmarks();
    _loadOfflineInstant();
    _startReadTimer();
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startReadTimer() {
    _readTimer?.cancel();
    _secondsOnPage = 0;
    _readTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _secondsOnPage++;
      if (_secondsOnPage >= 180) {
        _recordHalamanDibaca();
        _secondsOnPage = 0;
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _recordHalamanDibaca() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = 'ngaji_${DateTime.now().toIso8601String().split('T')[0]}';
    await prefs.setInt(todayKey, (prefs.getInt(todayKey) ?? 0) + 1);
  }

  Future<void> _saveLastRead(int ayatNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read', json.encode({'surahNo': widget.surahNumber, 'surahName': widget.surahName, 'ayat': ayatNo, 'hlm': currentHlm}));
  }

  void _generateHlmList() {
    final start = surahStartPage[widget.surahNumber] ?? 1;
    final end = getSurahEndPage(widget.surahNumber);
    hlmList = List.generate(end - start + 1, (i) => start + i);
    if (hlmList.length > 20) hlmList = hlmList.take(20).toList();
  }

  void _loadOfflineInstant() {
    final data = getSurahOffline(widget.surahNumber);
    if (data != null) {
      final list = List<Map<String, dynamic>>.from(data['ayat']);
      setState(() { ayatList = list; _createPages(list); isLoading = false; });
      if (widget.initialAyat != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAyat(widget.initialAyat!));
      }
    }
    _syncOnlineBackground();
  }

  void _createPages(List<Map<String, dynamic>> allAyat) {
    final start = surahStartPage[widget.surahNumber] ?? 1;
    final end = getSurahEndPage(widget.surahNumber);
    final total = end - start + 1;
    if (total <= 1 || allAyat.length <= 5) { pages = [allAyat]; return; }
    final perPage = (allAyat.length / total).ceil();
    pages = [];
    for (var i = 0; i < allAyat.length; i += perPage) {
      final endIdx = i + perPage > allAyat.length ? allAyat.length : i + perPage;
      pages.add(allAyat.sublist(i, endIdx));
    }
    if (pages.isEmpty) pages = [allAyat];
  }

  void _scrollToAyat(int ayatNo) {
    for (int p = 0; p < pages.length; p++) {
      if (pages[p].any((a) => a['no'] == ayatNo)) {
        final rtlIdx = pages.length - 1 - p;
        _pageController.jumpToPage(rtlIdx);
        setState(() => currentHlm = (surahStartPage[widget.surahNumber] ?? 1) + p);
        _saveLastRead(ayatNo);
        return;
      }
    }
  }

  Future<void> _syncOnlineBackground() async {
    try {
      final url = Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,id.indonesian');
      final r = await http.get(url).timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final data = json.decode(r.body)['data'];
        final arab = data[0]['ayahs'] as List;
        final indo = data[1]['ayahs'] as List;
        List<Map<String, dynamic>> comb = [];
        for (int i = 0; i < arab.length; i++) {
          comb.add({"no": arab[i]['numberInSurah'], "arab": arab[i]['text'], "indo": indo[i]['text']});
        }
        if (mounted) setState(() { ayatList = comb; _createPages(comb); });
      }
    } catch (_) {}
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => bookmarkedAyats = (prefs.getStringList('bookmarks') ?? []).toSet());
  }

  Future<void> _toggleBookmark(int ayatNo) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.surahNumber}:$ayatNo';
    setState(() {
      if (bookmarkedAyats.contains(key)) bookmarkedAyats.remove(key);
      else bookmarkedAyats.add(key);
    });
    await prefs.setStringList('bookmarks', bookmarkedAyats.toList());
  }

  @override
  Widget build(BuildContext context) {
    final startPage = surahStartPage[widget.surahNumber] ?? 1;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.surahNumber}. ${widget.surahName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Hlm $currentHlm • ${isFullMushaf ? "Full Mushaf Rapat" : "Dengan Terjemahan"}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(isFullMushaf ? Icons.menu_book : Icons.translate, color: const Color(0xFFD4AF37)), onPressed: () => setState(() => isFullMushaf = !isFullMushaf)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            height: 46,
            color: const Color(0xFF0A1F3D),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: hlmList.length,
                    itemBuilder: (_, i) {
                      final hlmNo = hlmList[i];
                      final isActive = hlmNo == currentHlm;
                      return InkWell(
                        onTap: () {
                          setState(() => currentHlm = hlmNo);
                          final pageIdx = hlmNo - startPage;
                          final rtlIdx = pages.length - 1 - pageIdx;
                          if (rtlIdx >= 0 && rtlIdx < pages.length) {
                            _pageController.animateToPage(rtlIdx, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            _startReadTimer();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: isActive ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Center(child: Text('Hlm. $hlmNo', style: TextStyle(color: isActive ? const Color(0xFF0D2A54) : Colors.white70, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D2A54)))
          : Column(
              children: [
                LinearProgressIndicator(value: _secondsOnPage / 180, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37))),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    reverse: true,
                    onPageChanged: (rtlIdx) {
                      final actualIdx = pages.length - 1 - rtlIdx;
                      setState(() => currentHlm = startPage + actualIdx);
                      _startReadTimer();
                      if (pages.isNotEmpty && actualIdx >= 0 && actualIdx < pages.length) {
                        _saveLastRead(pages[actualIdx].first['no']);
                      }
                    },
                    itemCount: pages.length,
                    itemBuilder: (_, rtlIdx) {
                      final actualIdx = pages.length - 1 - rtlIdx;
                      if (actualIdx < 0 || actualIdx >= pages.length) return const SizedBox();
                      final pageAyats = pages[actualIdx];
                      if (isFullMushaf) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(6),
                          child: Container(
                            decoration: BoxDecoration(color: const Color(0xFFFFFEF7), border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25), width: 1.2)),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F8E9), border: Border(bottom: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.2)))),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E7D32), width: 1)),
                                        child: Text('سُوْرَةُ ${widget.surahArab}', style: GoogleFonts.amiriQuran(fontSize: 14, fontWeight: FontWeight.bold)),
                                      ),
                                      if (widget.surahNumber != 1 && widget.surahNumber != 9 && actualIdx == 0)
                                        Padding(padding: const EdgeInsets.only(top: 6), child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: GoogleFonts.amiriQuran(fontSize: 16))),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        for (var ayat in pageAyats) ...[
                                          TextSpan(text: '${ayat['arab']} ', style: GoogleFonts.amiriQuran(fontSize: fontSize - 1, height: 2.3, color: const Color(0xFF1A1A1A))),
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E7D32), width: 1), shape: BoxShape.circle),
                                              child: Text('${ayat['no']}', style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          const TextSpan(text: ' '),
                                        ]
                                      ],
                                    ),
                                    textAlign: TextAlign.justify,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: pageAyats.map((ayat) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0D2A54), borderRadius: BorderRadius.circular(12)), child: Text('${ayat['no']}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold))),
                                        InkWell(onTap: () => _toggleBookmark(ayat['no']), child: Icon(bookmarkedAyats.contains('${widget.surahNumber}:${ayat['no']}') ? Icons.bookmark : Icons.bookmark_border, size: 18, color: const Color(0xFFD4AF37))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(ayat['arab'] ?? '', textAlign: TextAlign.right, style: GoogleFonts.amiriQuran(fontSize: 28, height: 1.8)),
                                    const SizedBox(height: 6),
                                    Text(ayat['indo'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
