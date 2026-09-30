import 'package:flutter/material.dart';

class TafsirPage extends StatelessWidget {
  const TafsirPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(backgroundColor: const Color(0xFF0D2A54), title: const Text('Tafsir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), centerTitle: true, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFFFF8E1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37))), child: const Icon(Icons.auto_stories, size: 40, color: Color(0xFF0D2A54))),
          const SizedBox(height: 16),
          const Text('Tafsir Al-Qur\'an', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2A54))),
          const SizedBox(height: 8),
          Text('Fitur tafsir lengkap\nakan segera hadir', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ]),
      ),
    );
  }
}
