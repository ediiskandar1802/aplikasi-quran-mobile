import 'package:flutter/material.dart';
import '../services/quran_service.dart';

class DetailSurahScreen extends StatelessWidget {
  final int nomorSurah;
  const DetailSurahScreen({super.key, required this.nomorSurah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Surah $nomorSurah')),
      body: FutureBuilder(
        future: QuranService.loadSurah(nomorSurah),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var surah = snapshot.data!;
          var verses = surah['verses'] as List;
          var terjemahan = surah['translations']['id']['text'] as Map;

          return ListView.builder(
            itemCount: verses.length,
            itemBuilder: (context, index) {
              var ayat = verses[index];
              String noAyat = ayat['id'].toString();
              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Arab nya
                      Text(
                        ayat['arabic'],
                        style: TextStyle(fontSize: 24, fontFamily: 'Amiri'),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 12),
                      // Terjemah Indonesia nya
                      Text(
                        terjemahan[noAyat]?? '',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}