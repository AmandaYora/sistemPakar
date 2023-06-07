import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiagnosaPage extends StatefulWidget {
  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage> {
  List<dynamic> gejala = [];
  Map<String, String> selectedKondisi = {};
  List<dynamic> kondisi = [];
  bool isLoading = true;

  Future<bool> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.sistempakarlambung.masuk.web.id/data'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        gejala = jsonDecode(response.body);
        gejala.sort((a, b) {
          int numA = int.parse(a['kdgejala'].replaceAll(RegExp(r'\D'), ''));
          int numB = int.parse(b['kdgejala'].replaceAll(RegExp(r'\D'), ''));
          return numA.compareTo(numB);
        });
        gejala.forEach((element) {
          selectedKondisi[element['kdgejala']] = 'Pilih jika sesuai';
        });
        return true;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> fetchKondisi() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.sistempakarlambung.masuk.web.id/kondisi'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        kondisi = jsonDecode(response.body);
        return await fetchData();
      } else {
        throw Exception('Failed to load kondisi');
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchKondisi().then((success) {
      setState(() {
        isLoading = false;
      });

      if (!success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Server gagal merespon. Silahkan coba lagi.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Diagnosa'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: gejala.length,
                  itemBuilder: (BuildContext context, int index) {
                    String formattedKdGejala = gejala[index]['kdgejala']
                        .replaceAll(RegExp(r'\D'), '')
                        .padLeft(3, '0');
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        leading: Text((index + 1).toString()),
                        title: Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: gejala[index]['nmgejala'],
                                child: Text(
                                  gejala[index]['nmgejala'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('G$formattedKdGejala'),
                            DropdownButton<String>(
                              value: selectedKondisi[gejala[index]['kdgejala']],
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedKondisi[gejala[index]['kdgejala']] =
                                      newValue!;
                                });
                              },
                              items: <String>[
                                'Pilih jika sesuai',
                                ...kondisi.map((value) => value['kondisi'])
                              ].map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                color: Colors.blue,
                child: TextButton(
                  onPressed: () {
                    // Logika untuk aksi tombol Diagnosa
                  },
                  child: Text(
                    'Diagnosa',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: DiagnosaPage(),
  ));
}
