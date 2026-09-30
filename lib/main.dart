
import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard.dart'; // <- TAMBAHIN INI BOS

void main() {
  runApp(const AlQuranApp());
}

class AlQuranApp extends StatelessWidget {
  const AlQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al-Quran Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D4A42)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      //Navigator.of(context).pushReplacement(
      //  MaterialPageRoute(builder: (_) => const SurahListPage()),
     // );
            // di dalam Timer ganti jadi:
      Navigator.of(context).pushReplacement(
        //MaterialPageRoute(builder: (_) => const DashboardPage()),
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4A42), // tosca gelap
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 850),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFFD4AF37)), // gold loading
          ],
        ),
      ),
    );
  }
}

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  final List<Map<String, String>> surahList = const [
    {"no": "1", "nama": "Al-Fatihah", "arti": "Pembukaan", "ayat": "7"},
    {"no": "2", "nama": "Al-Baqarah", "arti": "Sapi Betina", "ayat": "286"},
    {"no": "3", "nama": "Ali 'Imran", "arti": "Keluarga Imran", "ayat": "200"},
    {"no": "36", "nama": "Yaasiin", "arti": "Yaasiin", "ayat": "83"},
    {"no": "55", "nama": "Ar-Rahman", "arti": "Yang Maha Pemurah", "ayat": "78"},
    {"no": "67", "nama": "Al-Mulk", "arti": "Kerajaan", "ayat": "30"},
    {"no": "112", "nama": "Al-Ikhlas", "arti": "Keikhlasan", "ayat": "4"},
    {"no": "113", "nama": "Al-Falaq", "arti": "Waktu Subuh", "ayat": "5"},
    {"no": "114", "nama": "An-Naas", "arti": "Manusia", "ayat": "6"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Al-Quran Al-Karim"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D4A42),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: surahList.length,
        itemBuilder: (context, index) {
          final surah = surahList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Text(surah["no"]!),
              ),
              title: Text(surah["nama"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${surah["arti"]} • ${surah["ayat"]} ayat"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}