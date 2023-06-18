import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'diagnosa_result_page.dart';
import 'config/config.dart';
import 'config/database.dart';
import 'main.dart';

class Penyakit {
  final int idPenyakit;
  final String namaPenyakit;
  final DateTime tanggalDiagnosis;
  final Map<String, Map<String, dynamic>> penyakitData;

  Penyakit(this.idPenyakit, this.namaPenyakit, this.tanggalDiagnosis,
      this.penyakitData);
}

class PenyakitListPage extends StatefulWidget {
  @override
  _PenyakitListPageState createState() => _PenyakitListPageState();
}

class _PenyakitListPageState extends State<PenyakitListPage> {
  List<Penyakit> daftarPenyakit = [];
  String uniqueId = '';
  String username = '';
  bool isLoading = false;

  Future<void> _loadUnique() async {
    List<User> users = await DatabaseHelper.getUsers();
    if (users.isNotEmpty) {
      setState(() {
        uniqueId = users[0].uniqueId;
        username = users[0].username;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUnique().then((_) {
      fetchPenyakit();
    });
  }

  fetchPenyakit() async {
    setState(() {
      isLoading = true; // Mulai memuat data
    });
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/hasil/detail/${uniqueId}'));

      print('Status code: ${response.statusCode}');
      print('Unique ID: $uniqueId');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          daftarPenyakit = (data["result"] as List).map((item) {
            Map<String, Map<String, dynamic>> penyakitData =
                (jsonDecode(item["penyakit"]) as Map).map((key, value) {
              return MapEntry(key, Map<String, dynamic>.from(value));
            });
            String namaPenyakit = penyakitData.entries.first.value["nama"];
            int idPenyakit = int.parse(item['id_hasil']);
            DateTime tanggalDiagnosis = DateTime.parse(item["tanggal"]);
            return Penyakit(
                idPenyakit, namaPenyakit, tanggalDiagnosis, penyakitData);
          }).toList();

          daftarPenyakit
              .sort((a, b) => b.tanggalDiagnosis.compareTo(a.tanggalDiagnosis));

          isLoading = false; // Selesai memuat data
        });
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pemberitahuan'),
            content: Text('Data diagnosa ${username} kosong !'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Dashboard()),
                    ModalRoute.withName(
                        '/'), // This makes sure that no other routes are before Dashboard
                  );
                },
              ),
            ],
          );
        },
      );
      setState(() {
        isLoading = false; // Selesai memuat data meskipun ada kesalahan
      });
    }
  }

  void removePenyakit(Penyakit penyakit) async {
    setState(() {
      daftarPenyakit.remove(penyakit);
    });

    try {
      final response = await http.delete(
          Uri.parse('${Config.apiUrl}/hasil/delete/${penyakit.idPenyakit}'));

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus penyakit');
      }
      print('Penyakit berhasil dihapus');
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal menghapus penyakit'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Penyakit'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Tampilkan CircularProgressIndicator saat memuat data
            : ListView.builder(
                itemCount: daftarPenyakit.length,
                itemBuilder: (BuildContext context, int index) {
                  Penyakit penyakit = daftarPenyakit[index];
                  return Dismissible(
                    key: Key(penyakit.idPenyakit.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Konfirmasi'),
                            content: Text('Anda yakin ingin menghapus?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Tidak'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: Text('Ya'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      removePenyakit(penyakit);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${penyakit.namaPenyakit} dihapus")));
                    },
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: Colors.red,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: Card(
                      elevation: 5.0,
                      child: ListTile(
                        title: Text(
                          penyakit.namaPenyakit,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Tanggal Diagnosis: ${penyakit.tanggalDiagnosis}',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        onTap: () {
                          var sortedScores = penyakit.penyakitData.entries
                              .toList()
                            ..sort((a, b) =>
                                b.value['score'].compareTo(a.value['score']));

                          Map<String, Map<String, dynamic>>
                              sortedPenyakitScores =
                              Map.fromEntries(sortedScores);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DiagnosaResultPage(
                                sortedPenyakitScores: sortedPenyakitScores,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
