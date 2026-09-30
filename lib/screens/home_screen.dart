FutureBuilder(
  future: QuranService.loadAllSurah(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    var list = snapshot.data!;
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(list[i]['name']),
        subtitle: Text(list[i]['translations']['id']['name']),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailSurahScreen(nomorSurah: list[i]['id'])),
        ),
      ),
    );
  },
)