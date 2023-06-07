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
          .get(Uri.parse(
              'https://api.sistempakarlambung.masuk.web.id/apiv3/index.php/gejala'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        gejala = decodedResponse['result'];
        gejala.sort((a, b) {
          int numA = int.parse(a['kode_gejala']);
          int numB = int.parse(b['kode_gejala']);
          return numA.compareTo(numB);
        });
        gejala.forEach((element) {
          selectedKondisi[element['kode_gejala']] = 'Pilih jika sesuai';
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
          .get(Uri.parse(
              'https://api.sistempakarlambung.masuk.web.id/apiv3/index.php/kondisi'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        kondisi = decodedResponse['result'];
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
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context)
                        .pop(); // Return to the previous page (main page)
                    // If the main page is not the previous page, replace this line with
                    // Navigator.of(context).pushNamed('<routeName>'); // Replace '<routeName>' with the actual route name of your main page
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
                    String formattedKdGejala =
                        gejala[index]['kode_gejala'].padLeft(3, '0');
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        leading: Text((index + 1).toString()),
                        title: Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: gejala[index]['nama_gejala'],
                                child: Text(
                                  gejala[index]['nama_gejala'],
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
                              value:
                                  selectedKondisi[gejala[index]['kode_gejala']],
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
                                  selectedKondisi[gejala[index]
                                      ['kode_gejala']] = newValue!;
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
