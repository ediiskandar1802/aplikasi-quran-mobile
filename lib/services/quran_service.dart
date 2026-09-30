import 'dart:convert';
import 'package:flutter/services.dart';

class QuranService {
  static Future<List<Map<String, dynamic>>> loadSurah(int nomorSurah) async {
    String jsonString = await rootBundle.loadString('assets/data/surah/$nomorSurah.json');
    Map<String, dynamic> json = jsonDecode(jsonString);
    var surahData = json['$nomorSurah']?? json;
    Map<String, dynamic> arabMap = {};
    if (surahData['text'] is Map) {
      arabMap = Map<String, dynamic>.from(surahData['text']);
    }
    Map<String, dynamic> indoMap = {};
    try {
      if (surahData['translations']!= null && surahData['translations']['id']!= null) {
        if (surahData['translations']['id']['text'] is Map) {
          indoMap = Map<String, dynamic>.from(surahData['translations']['id']['text']);
        }
      }
    } catch (_) {}
    List<Map<String, dynamic>> result = [];
    arabMap.forEach((key, value) {
      result.add({
        "no": int.tryParse(key)?? result.length + 1,
        "arab": value.toString(),
        "indo": indoMap[key]?.toString()?? "",
      });
    });
    result.sort((a, b) => (a['no'] as int).compareTo(b['no'] as int));
    return result;
  }
}