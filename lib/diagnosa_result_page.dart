import 'package:flutter/material.dart';

class DiagnosaResultPage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> sortedPenyakitScores;

  DiagnosaResultPage({required this.sortedPenyakitScores});

  @override
  Widget build(BuildContext context) {
    var sortedScores = sortedPenyakitScores.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Diagnosa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penyakit yang Diduga: ${sortedScores[0].value['nama']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: sortedScores[0].value['score'],
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            SizedBox(height: 16),
            Text(
              'Skor: ${(sortedScores[0].value['score']*100).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 20, color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            Text(
              'Detail Penyakit:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${sortedScores[0].value['detail']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(height: 2, color: Colors.black),
            SizedBox(height: 16),
            Text(
              'Kemungkinan Lain:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sortedScores.length - 1,
                itemBuilder: (BuildContext context, int index) {
                  String penyakit = sortedScores[index + 1].value['nama'];
                  double score = sortedScores[index + 1].value['score'];
                  return ListTile(
                    title: Text(
                      penyakit,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Skor: ${(score*100).toStringAsFixed(2)}%',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
