import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/config.dart';
import 'package:intl/intl.dart';
import 'diagnosa_result_page.dart';
import 'config/database.dart';

class DiagnosaPage extends StatefulWidget {
  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage> {
  List<dynamic> gejala = [];
  Map<String, String> selectedKondisi = {};
  List<dynamic> kondisi = [];
  bool isLoading = true;
  String unique_id = '';

  Map<String, double> bobotKondisi = {
    'Pasti ya': 1,
    'Hampir pasti ya': 0.8,
    'Kemungkinan besar ya': 0.6,
    'Mungkin ya': 0.4,
    'Tidak tahu': -0.2,
    'Mungkin tidak': -0.4,
    'Kemungkinan besar tidak': -0.6,
    'Hampir pasti tidak': -0.8,
    'Pasti tidak': -1
  };

  Future<void> diagnose(BuildContext context) async {
    // Count how many symptoms have been selected
    int selectedCount = selectedKondisi.values
        .where((value) => value != 'Pilih jika sesuai')
        .length;

    // Check if at least one symptom has been selected
    if (selectedCount <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Silahkan pilih minimal satu gejala.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      var responsePenyakit =
          await http.get(Uri.parse('${Config.apiUrl}/penyakit'));
      var penyakitList = jsonDecode(responsePenyakit.body)['result'] as List;

      var responsePengetahuan =
          await http.get(Uri.parse('${Config.apiUrl}/pengetahuan'));
      var pengetahuanList =
          jsonDecode(responsePengetahuan.body)['result'] as List;

      Map<String, Map<String, dynamic>> penyakitScores = {};

      for (var penyakit in penyakitList) {
        double cflama = 0;
        double cfskr = 0;

        for (var pengetahuan in pengetahuanList) {
          if (pengetahuan['kode_penyakit'] == penyakit['kode_penyakit'] &&
              selectedKondisi.containsKey(pengetahuan['kode_gejala'])) {
            double? bobot =
                bobotKondisi[selectedKondisi[pengetahuan['kode_gejala']]!];
            if (bobot == null) continue;

            double cf = (double.parse(pengetahuan['nilai_mb']) -
                    double.parse(pengetahuan['nilai_md'])) *
                bobot;

            if (cflama == 0) {
              cflama = cf;
            } else {
              cfskr = cf;
              cflama = cflama + cfskr * (1 - cflama);
            }

            if (cflama > 0) {
              penyakitScores[penyakit['kode_penyakit']] = {
                'score': cflama,
                'nama': penyakit['nama_penyakit'],
                'detail': penyakit['detail_penyakit'],
                'saran' : penyakit['saran'],
                'gambar': penyakit['gambar'],
              };
            }
          }
        }
      }

      var sortedScores = penyakitScores.entries.toList()
        ..sort((a, b) => b.value['score'].compareTo(a.value['score']));

      Map<String, Map<String, dynamic>> sortedPenyakitScores =
          Map.fromEntries(sortedScores);

      // serialize sortedPenyakitScores
      String jsonPenyakitScores = jsonEncode(sortedPenyakitScores);
      String jsonGejala = jsonEncode(selectedKondisi);
      var highestScoredPenyakitId = sortedScores[0].key;
      double highestScore = sortedScores[0].value['score'];
      String highestScoreString = highestScore.toString();
      var now = DateTime.now();
      var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      String formattedDate = formatter.format(now);

      // prepare data for http post
      Map<String, String> body = {
        'tanggal': formattedDate, // replace with actual value
        'gejala': jsonGejala, // replace with actual value
        'penyakit': jsonPenyakitScores,
        'hasil_id': highestScoredPenyakitId, // replace with actual value
        'hasil_nilai': highestScoreString,
        'unique_id': unique_id // replace with actual value
      };

      // send http post request
      var response = await http.post(
        Uri.parse('${Config.apiUrl}/hasil/simpan'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // check response status code
      if (response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DiagnosaResultPage(
              sortedPenyakitScores: sortedPenyakitScores,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Gagal mendiagnosa data.' + unique_id),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
        print('Failed to diagnose data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Caught error: $e');
    }
  }

  Future<bool> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/gejala'))
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
      return false;
    }
  }

  Future<bool> fetchKondisi() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/kondisi'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        kondisi = decodedResponse['result'];
        return await fetchData();
      } else {
        throw Exception('Failed to load kondisi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
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
    _loadUniqueId();
  }

  Future<void> _loadUniqueId() async {
    List<User> users = await DatabaseHelper.getUsers();
    if (users.isNotEmpty) {
      setState(() {
        unique_id = users[0].uniqueId;
      });
    }
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
                                ...bobotKondisi.keys.toList(),
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
                  onPressed: () => diagnose(context),
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
