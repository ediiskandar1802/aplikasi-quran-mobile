import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});
  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  String selectedWilayah = 'Kota Jakarta Selatan';
  final List<String> wilayahList = [
    'Kota Jakarta Selatan','Kota Jakarta Pusat','Kota Jakarta Utara','Kota Jakarta Barat','Kota Jakarta Timur','Kota Bandung','Kota Surabaya','Kota Yogyakarta','Kota Medan','Kota Makassar','Kota Semarang','Kota Malang','Kota Palembang','Kota Denpasar',
  ];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); setState(()=>selectedWilayah=p.getString('selected_wilayah')??'Kota Jakarta Selatan'); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF2),
      appBar: AppBar(backgroundColor: const Color(0xFF0D2A54), title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), centerTitle: true, iconTheme: const IconThemeData(color: Colors.white)),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          const Padding(padding: EdgeInsets.fromLTRB(16,12,16,4), child: Text('Wilayah & Jadwal Shalat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D2A54)))),
          ListTile(leading: const Icon(Icons.location_on, color: Color(0xFF0D2A54)), title: const Text('Wilayah'), subtitle: Text(selectedWilayah, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)), trailing: const Icon(Icons.chevron_right), onTap: ()=>_showWilayah()),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(padding: const EdgeInsets.all(12), child: Text('Jadwal shalat otomatis menyesuaikan wilayah', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
        ])),
      ]),
    );
  }

  void _showWilayah() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.5, expand: false, builder: (_, ctrl) => Column(children:[
      Container(margin: const EdgeInsets.only(top:12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      const Padding(padding: EdgeInsets.all(16), child: Text('Pilih Wilayah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
      Expanded(child: ListView.builder(controller: ctrl, itemCount: wilayahList.length, itemBuilder: (_, i){ final w=wilayahList[i]; final sel=w==selectedWilayah; return ListTile(title: Text(w, style: TextStyle(fontWeight: sel?FontWeight.bold:FontWeight.normal)), trailing: sel?const Icon(Icons.check_circle, color: Color(0xFFD4AF37)):null, onTap: () async { final p=await SharedPreferences.getInstance(); await p.setString('selected_wilayah', w); setState(()=>selectedWilayah=w); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wilayah diganti ke $w'))); }); })),
    ])));
  }
}
