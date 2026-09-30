import 'package:flutter/material.dart';

class DoaHarianPage extends StatefulWidget {
  const DoaHarianPage({super.key});

  @override
  State<DoaHarianPage> createState() => _DoaHarianPageState();
}

class _DoaHarianPageState extends State<DoaHarianPage> {
  int selectedTab = 0;
  final tabs = ['Pagi', 'Petang', 'Sebelum Tidur'];

  final List<Map<String, dynamic>> allDoa = [
    {"kategori": "Pagi", "icon": "☀️", "judul": "Doa bangun tidur, pagi, dll.", "arab": "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ", "indo": "Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan kepada-Nya kami akan kembali.", "count": 12},
    {"kategori": "Pagi", "icon": "🕌", "judul": "Doa masuk masjid", "arab": "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ", "indo": "Ya Allah, bukakanlah untukku pintu-pintu rahmat-Mu.", "count": 1},
    {"kategori": "Pagi", "icon": "🏠", "judul": "Doa keluar rumah", "arab": "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", "indo": "Dengan nama Allah, aku bertawakal kepada Allah, tiada daya dan kekuatan kecuali dengan Allah.", "count": 1},
    {"kategori": "Pagi", "icon": "🍽️", "judul": "Doa sebelum makan", "arab": "اللَّهُمَّ بَارِكْ لَنَا فِيمَا رَزَقْتَنَا وَقِنَا عَذَابَ النَّارِ", "indo": "Ya Allah, berkahilah rezeki yang Engkau berikan kepada kami, dan peliharalah kami dari siksa api neraka.", "count": 1},
    {"kategori": "Pagi", "icon": "🤲", "judul": "Doa setelah makan", "arab": "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ", "indo": "Segala puji bagi Allah yang memberi kami makan dan minum serta menjadikan kami orang-orang muslim.", "count": 1},
    {"kategori": "Pagi", "icon": "❤️", "judul": "Doa keselamatan", "arab": "اللَّهُمَّ إِنَّا نَسْأَلُكَ سَلَامَةً فِي الدِّينِ وَعَافِيَةً فِي الْجَسَدِ", "indo": "Ya Allah, kami memohon keselamatan dalam agama, kesehatan dalam tubuh.", "count": 1},
    {"kategori": "Petang", "icon": "🌙", "judul": "Doa sore hari", "arab": "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ", "indo": "Kami memasuki sore hari dan kerajaan hanya milik Allah.", "count": 1},
    {"kategori": "Petang", "icon": "🏠", "judul": "Doa masuk rumah", "arab": "اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلَجِ وَخَيْرَ الْمَخْرَجِ", "indo": "Ya Allah, aku memohon kepada-Mu kebaikan tempat masuk dan kebaikan tempat keluar.", "count": 1},
    {"kategori": "Sebelum Tidur", "icon": "😴", "judul": "Doa sebelum tidur", "arab": "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا", "indo": "Dengan nama-Mu ya Allah, aku mati dan aku hidup.", "count": 1},
    {"kategori": "Sebelum Tidur", "icon": "🛏️", "judul": "Doa mimpi buruk", "arab": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَمَلِ الشَّيْطَانِ وَسَيِّئَاتِ الْأَحْلَامِ", "indo": "Ya Allah, aku berlindung kepada-Mu dari perbuatan setan dan keburukan mimpi.", "count": 1},
  ];

  List<Map<String, dynamic>> get filteredDoa {
    final cat = tabs[selectedTab];
    return allDoa.where((d) => d['kategori'] == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Doa Harian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF0D2A54),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isActive = i == selectedTab;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: InkWell(
                      onTap: () => setState(() => selectedTab = i),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tabs[i], textAlign: TextAlign.center, style: TextStyle(color: isActive ? const Color(0xFF0D2A54) : Colors.white70, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredDoa.length,
              itemBuilder: (_, idx) {
                final doa = filteredDoa[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                      child: Center(child: Text(doa['icon'], style: const TextStyle(fontSize: 18))),
                    ),
                    title: Text(doa['judul'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0D2A54))),
                    subtitle: Text('${doa['count']} doa • Tap untuk baca', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                    onTap: () => _showDoaDetail(doa),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDoaDetail(Map<String, dynamic> doa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(doa['judul'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2A54)), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF8F6F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                child: Text(doa['arab'], textAlign: TextAlign.right, style: const TextStyle(fontSize: 22, height: 1.8, color: Color(0xFF0D2A54))),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: Text(doa['indo'], style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 18, color: Colors.white),
                  label: const Text('Bagikan Doa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2A54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
