import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'data/quran_offline_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Map<int,int> surahStartPage={1:1,2:2,3:50,4:77,5:106,6:128,7:151,8:177,9:187,10:208,11:221,12:235,13:249,14:255,15:262,16:267,17:282,18:293,19:305,20:312,21:322,22:332,23:342,24:350,25:359,26:367,27:377,28:385,29:396,30:404,31:411,32:415,33:418,34:428,35:434,36:440,37:446,38:453,39:458,40:467,41:477,42:483,43:489,44:496,45:499,46:502,47:507,48:511,49:515,50:518,51:520,52:523,53:526,54:528,55:531,56:534,57:537,58:542,59:545,60:549,61:551,62:553,63:554,64:556,65:558,66:560,67:562,68:564,69:566,70:568,71:570,72:572,73:575,74:577,75:580,76:582,77:583,78:586,80:587,84:589,85:590,86:591,88:592,89:593,90:594,91:595,93:596,95:597,97:598,99:599,101:600,103:601,105:601,106:602,108:602,109:603,111:603,112:604};
int getEnd(int n){if(n>=114) return 604; return (surahStartPage[n+1]??604)-1;}

class SurahDetailPage extends StatefulWidget{
  final int surahNumber; final String surahName; final String surahArab; final int? initialAyat;
  const SurahDetailPage({super.key,required this.surahNumber,required this.surahName,required this.surahArab,this.initialAyat});
  @override State<SurahDetailPage> createState()=>_SState();
}

class _SState extends State<SurahDetailPage>{
  List<Map<String,dynamic>> ayatList=[]; List<List<Map<String,dynamic>>> pages=[]; bool load=true; bool full=true;
  Set<String> books={}; double fSize=30; int curHlm=1; List<int> hlmList=[]; final PageController pc=PageController(); Timer? timer; int sec=0;

  @override void initState(){super.initState(); curHlm=surahStartPage[widget.surahNumber]??1; _gen(); _loadB(); _loadO(); _start();}
  @override void dispose(){timer?.cancel(); pc.dispose(); super.dispose();}
  void _start(){timer?.cancel(); sec=0; timer=Timer.periodic(const Duration(seconds:1),(t){sec++; if(sec>=180){_rec(); sec=0;} if(mounted) setState((){});});}
  Future<void> _rec() async {final p=await SharedPreferences.getInstance(); final k='ngaji_${DateTime.now().toIso8601String().split('T')[0]}'; await p.setInt(k,(p.getInt(k)??0)+1);}
  Future<void> _save(int a) async {final p=await SharedPreferences.getInstance(); await p.setString('last_read',json.encode({'surahNo':widget.surahNumber,'surahName':widget.surahName,'ayat':a,'hlm':curHlm}));}
  void _gen(){final s=surahStartPage[widget.surahNumber]??1; final e=getEnd(widget.surahNumber); hlmList=List.generate(e-s+1,(i)=>s+i); if(hlmList.length>20) hlmList=hlmList.take(20).toList();}
  void _loadO(){final d=getSurahOffline(widget.surahNumber); if(d!=null){final l=List<Map<String,dynamic>>.from(d['ayat']); setState((){ayatList=l; _cp(l); load=false;}); if(widget.initialAyat!=null) WidgetsBinding.instance.addPostFrameCallback((_)=>_to(widget.initialAyat!));} _sync();}
  void _cp(List<Map<String,dynamic>> all){final s=surahStartPage[widget.surahNumber]??1; final e=getEnd(widget.surahNumber); final tot=e-s+1; if(tot<=1||all.length<=5){pages=[all]; return;} final per=(all.length/tot).ceil(); pages=[]; for(var i=0;i<all.length;i+=per) pages.add(all.sublist(i,i+per>all.length?all.length:i+per));}
  void _to(int a){for(int p=0;p<pages.length;p++){if(pages[p].any((x)=>x['no']==a)){pc.jumpToPage(pages.length-1-p); setState(()=>curHlm=(surahStartPage[widget.surahNumber]??1)+p); _save(a); return;}}}
  Future<void> _sync() async {try{final url=Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,id.indonesian'); final r=await http.get(url).timeout(const Duration(seconds:8)); if(r.statusCode==200){final data=json.decode(r.body)['data']; final arab=data[0]['ayahs'] as List; final indo=data[1]['ayahs'] as List; List<Map<String,dynamic>> c=[]; for(int i=0;i<arab.length;i++) c.add({"no":arab[i]['numberInSurah'],"arab":arab[i]['text'],"indo":indo[i]['text']}); if(mounted) setState((){ayatList=c; _cp(c);});}}catch(_){}}
  Future<void> _loadB() async {final p=await SharedPreferences.getInstance(); setState(()=>books=(p.getStringList('bookmarks')??[]).toSet());}
  Future<void> _tog(int n) async {final p=await SharedPreferences.getInstance(); final k='${widget.surahNumber}:$n'; setState((){if(books.contains(k)) books.remove(k); else books.add(k);}); await p.setStringList('bookmarks',books.toList());}

  @override Widget build(BuildContext context){
    final s=surahStartPage[widget.surahNumber]??1;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54), iconTheme: const IconThemeData(color:Colors.white),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('${widget.surahNumber}. ${widget.surahName}', style: const TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:15)), Text('Hlm $curHlm • ${full?"Tanpa Terjemahan":"Dengan Terjemahan"}', style: const TextStyle(color:Colors.white70, fontSize:10))]),
        actions:[IconButton(icon: Icon(full?Icons.menu_book:Icons.translate, color: const Color(0xFFD4AF37)), onPressed:()=>setState(()=>full=!full))],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(46), child: Container(height:46, color: const Color(0xFF0A1F3D), child: Row(children:[const SizedBox(width:8), Expanded(child: ListView.builder(scrollDirection: Axis.horizontal, reverse:true, padding: const EdgeInsets.symmetric(horizontal:8), itemCount: hlmList.length, itemBuilder: (_,i){final h=hlmList[i]; final act=h==curHlm; return InkWell(onTap:(){setState(()=>curHlm=h); final pi=h-s; final r=pages.length-1-pi; if(r>=0&&r<pages.length){pc.animateToPage(r, duration: const Duration(milliseconds:300), curve: Curves.ease); _start();}}, child: Container(margin: const EdgeInsets.symmetric(horizontal:4, vertical:7), padding: const EdgeInsets.symmetric(horizontal:16), decoration: BoxDecoration(color: act? const Color(0xFFD4AF37):Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Center(child: Text('Hlm. $h', style: TextStyle(color: act? const Color(0xFF0D2A54):Colors.white70, fontWeight: act?FontWeight.bold:FontWeight.normal, fontSize:13)))));})), IconButton(icon: const Icon(Icons.menu_book, color: Color(0xFFD4AF37), size:20), onPressed:(){}),]))),
      body: load? const Center(child:CircularProgressIndicator(color: Color(0xFF0D2A54))): Column(children:[
        LinearProgressIndicator(value: sec/180, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37))),
        Expanded(child: PageView.builder(
          controller: pc, reverse:true,
          onPageChanged: (r){final a=pages.length-1-r; final h=s+a; setState(()=>curHlm=h); _start(); if(pages.isNotEmpty&&a<pages.length) _save(pages[a].first['no']);},
          itemCount: pages.length,
          itemBuilder: (_,rIdx){
            final aIdx=pages.length-1-rIdx; if(aIdx<0||aIdx>=pages.length) return const SizedBox(); final pAyats=pages[aIdx];
            if(full){
              return SingleChildScrollView(padding: const EdgeInsets.all(6), child: Container(decoration: BoxDecoration(color: const Color(0xFFFFFEF7), border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25), width:1.2)), child: Column(children:[
                Container(width:double.infinity, padding: const EdgeInsets.symmetric(vertical:8), decoration: BoxDecoration(color: const Color(0xFFF1F8E9), border: Border(bottom: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.2)))), child: Column(children:[Container(padding: const EdgeInsets.symmetric(horizontal:16, vertical:3), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E7D32), width:1)), child: Text('سُوْرَةُ ${widget.surahArab}', style: GoogleFonts.amiriQuran(fontSize:14, fontWeight:FontWeight.bold))), if(widget.surahNumber!=1&&widget.surahNumber!=9&&aIdx==0) Padding(padding: const EdgeInsets.only(top:6), child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', style: GoogleFonts.amiriQuran(fontSize:16)))])),
                Padding(padding: const EdgeInsets.fromLTRB(12,10,12,12), child: Text.rich(TextSpan(children:[for(var ay in pAyats)...[TextSpan(text:'${ay['arab']} ', style: GoogleFonts.amiriQuran(fontSize: fSize-1, height:2.3, color: const Color(0xFF1A1A1A))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(margin: const EdgeInsets.symmetric(horizontal:3), padding: const EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E7D32), width:1), shape: BoxShape.circle), child: Text('${ay['no']}', style: const TextStyle(fontSize:9, color: Color(0xFF2E7D32), fontWeight:FontWeight.bold)))), const TextSpan(text:' ')]]), textAlign: TextAlign.justify, textDirection: TextDirection.rtl)),
              ]))),
            }
            return SingleChildScrollView(padding: const EdgeInsets.all(12), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))), padding: const EdgeInsets.all(14), child: Column(children: pAyats.map((ay)=>Container(margin: const EdgeInsets.only(bottom:12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children:[Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:2), decoration: BoxDecoration(color: const Color(0xFF0D2A54), borderRadius: BorderRadius.circular(12)), child: Text('${ay['no']}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize:11, fontWeight:FontWeight.bold))), InkWell(onTap:()=>_tog(ay['no']), child: Icon(books.contains('${widget.surahNumber}:${ay['no']}')?Icons.bookmark:Icons.bookmark_border, size:18, color: const Color(0xFFD4AF37)))]), const SizedBox(height:6), Text(ay['arab']??'', textAlign: TextAlign.right, style: GoogleFonts.amiriQuran(fontSize:28, height:1.8)), const SizedBox(height:6), Text(ay['indo']??'', style: GoogleFonts.inter(fontSize:12, color: Colors.grey.shade700))]))).toList())));
          },
        )),
      ]),
    );
  }
}
