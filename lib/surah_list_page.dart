import 'package:flutter/material.dart';
import 'surah_detail_page.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  final List<Map<String, dynamic>> surahList = const [
    {"no": 1, "arab": "الفاتحة", "latin": "Al-Fatihah", "arti": "Pembukaan", "ayat": 7, "tempat": "Mekkah"},
    {"no": 2, "arab": "البقرة", "latin": "Al-Baqarah", "arti": "Sapi Betina", "ayat": 286, "tempat": "Madinah"},
    {"no": 3, "arab": "آل عمران", "latin": "Ali 'Imran", "arti": "Keluarga Imran", "ayat": 200, "tempat": "Madinah"},
    {"no": 4, "arab": "النساء", "latin": "An-Nisa", "arti": "Wanita", "ayat": 176, "tempat": "Madinah"},
    {"no": 5, "arab": "المائدة", "latin": "Al-Ma'idah", "arti": "Hidangan", "ayat": 120, "tempat": "Madinah"},
    {"no": 6, "arab": "الأنعام", "latin": "Al-An'am", "arti": "Binatang Ternak", "ayat": 165, "tempat": "Mekkah"},
    {"no": 7, "arab": "الأعراف", "latin": "Al-A'raf", "arti": "Tempat Tertinggi", "ayat": 206, "tempat": "Mekkah"},
    {"no": 8, "arab": "الأنفال", "latin": "Al-Anfal", "arti": "Rampasan Perang", "ayat": 75, "tempat": "Madinah"},
    {"no": 9, "arab": "التوبة", "latin": "At-Taubah", "arti": "Pengampunan", "ayat": 129, "tempat": "Madinah"},
    {"no": 10, "arab": "يونس", "latin": "Yunus", "arti": "Nabi Yunus", "ayat": 109, "tempat": "Mekkah"},
    {"no": 11, "arab": "هود", "latin": "Hud", "arti": "Nabi Hud", "ayat": 123, "tempat": "Mekkah"},
    {"no": 12, "arab": "يوسف", "latin": "Yusuf", "arti": "Nabi Yusuf", "ayat": 111, "tempat": "Mekkah"},
    {"no": 13, "arab": "الرعد", "latin": "Ar-Ra'd", "arti": "Guruh", "ayat": 43, "tempat": "Madinah"},
    {"no": 14, "arab": "إبراهيم", "latin": "Ibrahim", "arti": "Nabi Ibrahim", "ayat": 52, "tempat": "Mekkah"},
    {"no": 15, "arab": "الحجر", "latin": "Al-Hijr", "arti": "Gunung Al-Hijr", "ayat": 99, "tempat": "Mekkah"},
    {"no": 16, "arab": "النحل", "latin": "An-Nahl", "arti": "Lebah", "ayat": 128, "tempat": "Mekkah"},
    {"no": 17, "arab": "الإسراء", "latin": "Al-Isra", "arti": "Memperjalankan", "ayat": 111, "tempat": "Mekkah"},
    {"no": 18, "arab": "الكهف", "latin": "Al-Kahf", "arti": "Penghuni Gua", "ayat": 110, "tempat": "Mekkah"},
    {"no": 19, "arab": "مريم", "latin": "Maryam", "arti": "Maryam", "ayat": 98, "tempat": "Mekkah"},
    {"no": 20, "arab": "طه", "latin": "Ta-Ha", "arti": "Ta Ha", "ayat": 135, "tempat": "Mekkah"},
    {"no": 21, "arab": "الأنبياء", "latin": "Al-Anbiya", "arti": "Para Nabi", "ayat": 112, "tempat": "Mekkah"},
    {"no": 22, "arab": "الحج", "latin": "Al-Hajj", "arti": "Haji", "ayat": 78, "tempat": "Madinah"},
    {"no": 23, "arab": "المؤمنون", "latin": "Al-Mu'minun", "arti": "Orang Mukmin", "ayat": 118, "tempat": "Mekkah"},
    {"no": 24, "arab": "النور", "latin": "An-Nur", "arti": "Cahaya", "ayat": 64, "tempat": "Madinah"},
    {"no": 25, "arab": "الفرقان", "latin": "Al-Furqan", "arti": "Pembeda", "ayat": 77, "tempat": "Mekkah"},
    {"no": 26, "arab": "الشعراء", "latin": "Asy-Syu'ara", "arti": "Penyair", "ayat": 227, "tempat": "Mekkah"},
    {"no": 27, "arab": "النمل", "latin": "An-Naml", "arti": "Semut", "ayat": 93, "tempat": "Mekkah"},
    {"no": 28, "arab": "القصص", "latin": "Al-Qashash", "arti": "Kisah", "ayat": 88, "tempat": "Mekkah"},
    {"no": 29, "arab": "العنكبوت", "latin": "Al-'Ankabut", "arti": "Laba-laba", "ayat": 69, "tempat": "Mekkah"},
    {"no": 30, "arab": "الروم", "latin": "Ar-Rum", "arti": "Bangsa Romawi", "ayat": 60, "tempat": "Mekkah"},
    {"no": 31, "arab": "لقمان", "latin": "Luqman", "arti": "Luqman", "ayat": 34, "tempat": "Mekkah"},
    {"no": 32, "arab": "السجدة", "latin": "As-Sajdah", "arti": "Sajdah", "ayat": 30, "tempat": "Mekkah"},
    {"no": 33, "arab": "الأحزاب", "latin": "Al-Ahzab", "arti": "Golongan Bersekutu", "ayat": 73, "tempat": "Madinah"},
    {"no": 34, "arab": "سبأ", "latin": "Saba", "arti": "Kaum Saba", "ayat": 54, "tempat": "Mekkah"},
    {"no": 35, "arab": "فاطر", "latin": "Fatir", "arti": "Pencipta", "ayat": 45, "tempat": "Mekkah"},
    {"no": 36, "arab": "يس", "latin": "Ya-Sin", "arti": "Ya Sin", "ayat": 83, "tempat": "Mekkah"},
    {"no": 37, "arab": "الصافات", "latin": "Ash-Shaffat", "arti": "Berbaris", "ayat": 182, "tempat": "Mekkah"},
    {"no": 38, "arab": "ص", "latin": "Shad", "arti": "Shaad", "ayat": 88, "tempat": "Mekkah"},
    {"no": 39, "arab": "الزمر", "latin": "Az-Zumar", "arti": "Rombongan", "ayat": 75, "tempat": "Mekkah"},
    {"no": 40, "arab": "غافر", "latin": "Ghafir", "arti": "Yang Mengampuni", "ayat": 85, "tempat": "Mekkah"},
    {"no": 41, "arab": "فصلت", "latin": "Fushshilat", "arti": "Yang Dijelaskan", "ayat": 54, "tempat": "Mekkah"},
    {"no": 42, "arab": "الشورى", "latin": "Asy-Syura", "arti": "Musyawarah", "ayat": 53, "tempat": "Mekkah"},
    {"no": 43, "arab": "الزخرف", "latin": "Az-Zukhruf", "arti": "Perhiasan", "ayat": 89, "tempat": "Mekkah"},
    {"no": 44, "arab": "الدخان", "latin": "Ad-Dukhan", "arti": "Kabut", "ayat": 59, "tempat": "Mekkah"},
    {"no": 45, "arab": "الجاثية", "latin": "Al-Jatsiyah", "arti": "Yang Bertekuk Lutut", "ayat": 37, "tempat": "Mekkah"},
    {"no": 46, "arab": "الأحقاف", "latin": "Al-Ahqaf", "arti": "Bukit Pasir", "ayat": 35, "tempat": "Mekkah"},
    {"no": 47, "arab": "محمد", "latin": "Muhammad", "arti": "Muhammad", "ayat": 38, "tempat": "Madinah"},
    {"no": 48, "arab": "الفتح", "latin": "Al-Fath", "arti": "Kemenangan", "ayat": 29, "tempat": "Madinah"},
    {"no": 49, "arab": "الحجرات", "latin": "Al-Hujurat", "arti": "Kamar", "ayat": 18, "tempat": "Madinah"},
    {"no": 50, "arab": "ق", "latin": "Qaf", "arti": "Qaf", "ayat": 45, "tempat": "Mekkah"},
    {"no": 51, "arab": "الذاريات", "latin": "Adz-Dzariyat", "arti": "Angin", "ayat": 60, "tempat": "Mekkah"},
    {"no": 52, "arab": "الطور", "latin": "Ath-Thur", "arti": "Bukit", "ayat": 49, "tempat": "Mekkah"},
    {"no": 53, "arab": "النجم", "latin": "An-Najm", "arti": "Bintang", "ayat": 62, "tempat": "Mekkah"},
    {"no": 54, "arab": "القمر", "latin": "Al-Qamar", "arti": "Bulan", "ayat": 55, "tempat": "Mekkah"},
    {"no": 55, "arab": "الرحمن", "latin": "Ar-Rahman", "arti": "Maha Pengasih", "ayat": 78, "tempat": "Madinah"},
    {"no": 56, "arab": "الواقعة", "latin": "Al-Waqi'ah", "arti": "Hari Kiamat", "ayat": 96, "tempat": "Mekkah"},
    {"no": 57, "arab": "الحديد", "latin": "Al-Hadid", "arti": "Besi", "ayat": 29, "tempat": "Madinah"},
    {"no": 58, "arab": "المجادلة", "latin": "Al-Mujadalah", "arti": "Gugatan", "ayat": 22, "tempat": "Madinah"},
    {"no": 59, "arab": "الحشر", "latin": "Al-Hasyr", "arti": "Pengusiran", "ayat": 24, "tempat": "Madinah"},
    {"no": 60, "arab": "الممتحنة", "latin": "Al-Mumtahanah", "arti": "Wanita Diuji", "ayat": 13, "tempat": "Madinah"},
    {"no": 61, "arab": "الصف", "latin": "Ash-Shaff", "arti": "Barisan", "ayat": 14, "tempat": "Madinah"},
    {"no": 62, "arab": "الجمعة", "latin": "Al-Jumu'ah", "arti": "Jumat", "ayat": 11, "tempat": "Madinah"},
    {"no": 63, "arab": "المنافقون", "latin": "Al-Munafiqun", "arti": "Munafik", "ayat": 11, "tempat": "Madinah"},
    {"no": 64, "arab": "التغابن", "latin": "At-Taghabun", "arti": "Pengungkapan", "ayat": 18, "tempat": "Madinah"},
    {"no": 65, "arab": "الطلاق", "latin": "Ath-Thalaq", "arti": "Talak", "ayat": 12, "tempat": "Madinah"},
    {"no": 66, "arab": "التحريم", "latin": "At-Tahrim", "arti": "Pengharaman", "ayat": 12, "tempat": "Madinah"},
    {"no": 67, "arab": "الملك", "latin": "Al-Mulk", "arti": "Kerajaan", "ayat": 30, "tempat": "Mekkah"},
    {"no": 68, "arab": "القلم", "latin": "Al-Qalam", "arti": "Pena", "ayat": 52, "tempat": "Mekkah"},
    {"no": 69, "arab": "الحاقة", "latin": "Al-Haqqah", "arti": "Hari Kiamat", "ayat": 52, "tempat": "Mekkah"},
    {"no": 70, "arab": "المعارج", "latin": "Al-Ma'arij", "arti": "Tempat Naik", "ayat": 44, "tempat": "Mekkah"},
    {"no": 71, "arab": "نوح", "latin": "Nuh", "arti": "Nabi Nuh", "ayat": 28, "tempat": "Mekkah"},
    {"no": 72, "arab": "الجن", "latin": "Al-Jinn", "arti": "Jin", "ayat": 28, "tempat": "Mekkah"},
    {"no": 73, "arab": "المزمل", "latin": "Al-Muzzammil", "arti": "Berselimut", "ayat": 20, "tempat": "Mekkah"},
    {"no": 74, "arab": "المدثر", "latin": "Al-Muddatsir", "arti": "Berselimut", "ayat": 56, "tempat": "Mekkah"},
    {"no": 75, "arab": "القيامة", "latin": "Al-Qiyamah", "arti": "Kiamat", "ayat": 40, "tempat": "Mekkah"},
    {"no": 76, "arab": "الإنسان", "latin": "Al-Insan", "arti": "Manusia", "ayat": 31, "tempat": "Madinah"},
    {"no": 77, "arab": "المرسلات", "latin": "Al-Mursalat", "arti": "Malaikat Diutus", "ayat": 50, "tempat": "Mekkah"},
    {"no": 78, "arab": "النبأ", "latin": "An-Naba", "arti": "Berita Besar", "ayat": 40, "tempat": "Mekkah"},
    {"no": 79, "arab": "النازعات", "latin": "An-Nazi'at", "arti": "Malaikat Pencabut", "ayat": 46, "tempat": "Mekkah"},
    {"no": 80, "arab": "عبس", "latin": "'Abasa", "arti": "Bermuka Masam", "ayat": 42, "tempat": "Mekkah"},
    {"no": 81, "arab": "التكوير", "latin": "At-Takwir", "arti": "Menggulung", "ayat": 29, "tempat": "Mekkah"},
    {"no": 82, "arab": "الانفطار", "latin": "Al-Infithar", "arti": "Terbelah", "ayat": 19, "tempat": "Mekkah"},
    {"no": 83, "arab": "المطففين", "latin": "Al-Muthaffifin", "arti": "Curang", "ayat": 36, "tempat": "Mekkah"},
    {"no": 84, "arab": "الانشقاق", "latin": "Al-Insyiqaq", "arti": "Terbelah", "ayat": 25, "tempat": "Mekkah"},
    {"no": 85, "arab": "البروج", "latin": "Al-Buruj", "arti": "Gugusan Bintang", "ayat": 22, "tempat": "Mekkah"},
    {"no": 86, "arab": "الطارق", "latin": "Ath-Thariq", "arti": "Yang Datang Malam", "ayat": 17, "tempat": "Mekkah"},
    {"no": 87, "arab": "الأعلى", "latin": "Al-A'la", "arti": "Maha Tinggi", "ayat": 19, "tempat": "Mekkah"},
    {"no": 88, "arab": "الغاشية", "latin": "Al-Ghasyiyah", "arti": "Hari Pembalasan", "ayat": 26, "tempat": "Mekkah"},
    {"no": 89, "arab": "الفجر", "latin": "Al-Fajr", "arti": "Fajar", "ayat": 30, "tempat": "Mekkah"},
    {"no": 90, "arab": "البلد", "latin": "Al-Balad", "arti": "Negeri", "ayat": 20, "tempat": "Mekkah"},
    {"no": 91, "arab": "الشمس", "latin": "Asy-Syams", "arti": "Matahari", "ayat": 15, "tempat": "Mekkah"},
    {"no": 92, "arab": "الليل", "latin": "Al-Lail", "arti": "Malam", "ayat": 21, "tempat": "Mekkah"},
    {"no": 93, "arab": "الضحى", "latin": "Adh-Dhuha", "arti": "Duha", "ayat": 11, "tempat": "Mekkah"},
    {"no": 94, "arab": "الشرح", "latin": "Al-Insyirah", "arti": "Kelapangan", "ayat": 8, "tempat": "Mekkah"},
    {"no": 95, "arab": "التين", "latin": "At-Tin", "arti": "Buah Tin", "ayat": 8, "tempat": "Mekkah"},
    {"no": 96, "arab": "العلق", "latin": "Al-'Alaq", "arti": "Segumpal Darah", "ayat": 19, "tempat": "Mekkah"},
    {"no": 97, "arab": "القدر", "latin": "Al-Qadr", "arti": "Kemuliaan", "ayat": 5, "tempat": "Mekkah"},
    {"no": 98, "arab": "البينة", "latin": "Al-Bayyinah", "arti": "Bukti Nyata", "ayat": 8, "tempat": "Madinah"},
    {"no": 99, "arab": "الزلزلة", "latin": "Az-Zalzalah", "arti": "Guncangan", "ayat": 8, "tempat": "Madinah"},
    {"no": 100, "arab": "العاديات", "latin": "Al-'Adiyat", "arti": "Kuda Perang", "ayat": 11, "tempat": "Mekkah"},
    {"no": 101, "arab": "القارعة", "latin": "Al-Qari'ah", "arti": "Hari Kiamat", "ayat": 11, "tempat": "Mekkah"},
    {"no": 102, "arab": "التكاثر", "latin": "At-Takatsur", "arti": "Bermegah", "ayat": 8, "tempat": "Mekkah"},
    {"no": 103, "arab": "العصر", "latin": "Al-'Ashr", "arti": "Masa", "ayat": 3, "tempat": "Mekkah"},
    {"no": 104, "arab": "الهمزة", "latin": "Al-Humazah", "arti": "Pengumpat", "ayat": 9, "tempat": "Mekkah"},
    {"no": 105, "arab": "الفيل", "latin": "Al-Fil", "arti": "Gajah", "ayat": 5, "tempat": "Mekkah"},
    {"no": 106, "arab": "قريش", "latin": "Quraisy", "arti": "Suku Quraisy", "ayat": 4, "tempat": "Mekkah"},
    {"no": 107, "arab": "الماعون", "latin": "Al-Ma'un", "arti": "Barang Berguna", "ayat": 7, "tempat": "Mekkah"},
    {"no": 108, "arab": "الكوثر", "latin": "Al-Kautsar", "arti": "Nikmat Banyak", "ayat": 3, "tempat": "Mekkah"},
    {"no": 109, "arab": "الكافرون", "latin": "Al-Kafirun", "arti": "Orang Kafir", "ayat": 6, "tempat": "Mekkah"},
    {"no": 110, "arab": "النصر", "latin": "An-Nashr", "arti": "Pertolongan", "ayat": 3, "tempat": "Madinah"},
    {"no": 111, "arab": "المسد", "latin": "Al-Masad", "arti": "Gejolak Api", "ayat": 5, "tempat": "Mekkah"},
    {"no": 112, "arab": "الإخلاص", "latin": "Al-Ikhlas", "arti": "Keikhlasan", "ayat": 4, "tempat": "Mekkah"},
    {"no": 113, "arab": "الفلق", "latin": "Al-Falaq", "arti": "Waktu Subuh", "ayat": 5, "tempat": "Mekkah"},
    {"no": 114, "arab": "الناس", "latin": "An-Nas", "arti": "Manusia", "ayat": 6, "tempat": "Mekkah"},
  ];

  List<Map<String, dynamic>> filteredList = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredList = surahList;
  }

  void _filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredList = surahList.where((surah) {
        final q = query.toLowerCase();
        return surah['latin'].toLowerCase().contains(q) ||
            surah['arti'].toLowerCase().contains(q) ||
            surah['no'].toString().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54),
        title: const Text('Al-Qur\'an - 114 Surah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF0D2A54),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: _filterSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari Surah (Al-Baqarah, Yasin...)',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final surah = filteredList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D2A54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('${surah['no']}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(surah['latin'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        Text(surah['arab'], style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, color: Color(0xFF0D2A54))),
                      ],
                    ),
                    subtitle: Text('${surah['arti']} • ${surah['ayat']} Ayat • ${surah['tempat']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailPage(
                            surahNumber: surah['no'],
                            surahName: surah['latin'],
                            surahArab: surah['arab'],
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
    );
  }
}
