import 'package:flutter/material.dart';

class JuzPage extends StatelessWidget {
  const JuzPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A54),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Juz 1-30', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemCount: 30,
        itemBuilder: (_, i) {
          return InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Buka Juz ${i + 1}'))),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: const Color(0xFF0D2A54), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${i + 1}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 8),
                  Text('Juz ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2A54), fontSize: 13)),
                  Text('Hlm ${(i * 20) + 1}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
