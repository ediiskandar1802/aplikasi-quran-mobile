import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

int getSurahEndPage(int no) {
  if (no >= 114) return 604;
  return (surahStartPage[no + 1]?? 604) - 1;
}

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String surahArab;
  final int? initialAyat;
  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.surahArab,
    this.initialAyat,
  });
  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> ayatList = [];
  List<List<Map<String, dynamic>>> pages = [];
  bool isLoading = true;
  bool isFullMushaf = true;
  int currentHlm = 1;
  List<int> hlmList = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    currentHlm = surahStartPage[widget.surahNumber]?? 1;
    _generateHlmList();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _generateHlmList() {
    final start = surahStartPage[widget.surahNumber]?? 1;
    final end = getSurahEndPage(widget.surahNumber);
    hlmList = List.generate(end - start + 1, (i) => start + i);
  }

  Future<void> _loadData() async {
    try {
      final list = await QuranService.loadSurah(widget.surahNumber);
      if (!mounted) return;
      setState(() {
        ayatList = list;
        _createPages(list);
        isLoading = false;
        currentHlm = surahStartPage[widget.surahNumber]?? 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pages.isNotEmpty && _pageController.hasClients) {
          _pageController.jumpToPage(pages.length - 1);
          if (widget.initialAyat!= null) {
            _scrollToAyat(widget.initialAyat!);
          }
        }
      });
    } catch (e) {
      debugPrint("GAGAL LOAD SURAH ${widget.surahNumber}: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _createPages(List<Map<String, dynamic>> allAyat) {
    final start = surahStartPage[widget.surahNumber]?? 1;
    final end = getSurahEndPage(widget.surahNumber);
    final totalHlm = end - start + 1;
    if (totalHlm <= 1 || allAyat.length <= 5) {
      pages = [allAyat];
      return;
    }
    final perPage = (allAyat.length / totalHlm).ceil();
    pages = [];
    for (var i = 0; i < allAyat.length; i += perPage) {
      final endIdx = i + perPage > allAyat.length? allAyat.length : i + perPage;
      pages.add(allAyat.sublist(i, endIdx));
    }
    if (pages.isEmpty) pages = [allAyat];
  }

  void _scrollToAyat(int ayatNo) {
    for (int p = 0; p < pages.length; p++) {
      if (pages[p].any((a) => a['no'] == ayatNo)) {
        final rtlIdx = pages.length - 1 - p;
        _pageController.jumpToPage(rtlIdx);
        setState(() => currentHlm = (surahStartPage[widget.surahNumber]?? 1) + p);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final startPage = surahStartPage[widget.surahNumber]?? 1;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.surahNumber}. ${widget.surahName}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Hlm $currentHlm • ${ayatList.length} ayat • ${isFullMushaf? "Mushaf" : "Terjemah"}',
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isFullMushaf? Icons.translate : Icons.menu_book, color: const Color(0xFFD4AF37)),
            onPressed: () => setState(() => isFullMushaf =!isFullMushaf),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            height: 46,
            color: const Color(0xFF0A1F3D),
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
                    final pageIdx = hlmNo - startPage;
                    final rtlIdx = pages.length - 1 - pageIdx;
                    if (rtlIdx >= 0 && rtlIdx < pages.length) {
                      _pageController.animateToPage(rtlIdx,
                          duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('Hlm $hlmNo',
                          style: TextStyle(
                              color: isActive? const Color(0xFF0D2A54) : Colors.white70,
                              fontWeight: isActive? FontWeight.bold : FontWeight.normal,
                              fontSize: 12)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: isLoading
         ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D2A54)))
          : PageView.builder(
              controller: _pageController,
              reverse: true,
              onPageChanged: (rtlIdx) {
                final actualIdx = pages.length - 1 - rtlIdx;
                setState(() => currentHlm = startPage + actualIdx);
              },
              itemCount: pages.length,
              itemBuilder: (context, rtlIdx) {
                final actualIdx = pages.length - 1 - rtlIdx;
                if (actualIdx < 0 || actualIdx >= pages.length) return const SizedBox();
                final pageAyats = pages[actualIdx];
                if (isFullMushaf) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFEF7),
                        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25), width: 1.2),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (actualIdx == 0 && widget.surahNumber!= 1 && widget.surahNumber!= 9)
                              TextSpan(
                                  text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n",
                                  style: GoogleFonts.scheherazadeNew(fontSize: 20, fontWeight: FontWeight.bold)),
                            for (var ayat in pageAyats)...[
                              TextSpan(
                                text: "${ayat['arab']} ",
                                style: GoogleFonts.scheherazadeNew(fontSize: 24, height: 2.2),
                              ),
                              WidgetSpan(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF2E7D32)), shape: BoxShape.circle),
                                  child: Text('${ayat['no']}',
                                      style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const TextSpan(text: " "),
                            ]
                          ],
                        ),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  );
                }
                // MODE 2: 1 AYAT 1 TERJEMAHAN - FIX NOMOR AYAT MUNCUL
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pageAyats.length,
              itemBuilder: (_, i) {
                final ayat = pageAyats[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ARAB + NOMOR AYAT DI UJUNG
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ayat['arab']?? '',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.scheherazadeNew(
                                fontSize: 26,
                                height: 1.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // NOMOR AYAT BULAT HIJAU
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF2E7D32), width: 1.2),
                              shape: BoxShape.circle,
                              color: const Color(0xFFF1F8E9),
                            ),
                            child: Text(
                              '${ayat['no']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      // TERJEMAH
                      Text(
                        ayat['indo']?? '',
                        style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text('QS ${widget.surahNumber}:${ayat['no']} • Hlm $currentHlm',
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                );
              },
            );
              },
            ),
    );
    
  }
}