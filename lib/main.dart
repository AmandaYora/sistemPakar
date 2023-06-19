import 'package:flutter/material.dart';
import 'diagnosa_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/database.dart';
import 'package:sqflite/sqflite.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'riwayat_list.dart';
import 'config/crypto.dart';
import 'config/service/excellent.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Penting untuk inisialisasi asinkron

  // Create the database
  await DatabaseHelper.database;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<User>>? users;
  bool _isParse = false;
  String status = '';
  DateTime getDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    users = DatabaseHelper.getUsers();
    fetchDate();
  }

  bool isAtSameDay(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  Future<void> fetchDate() async {
    final response = await http.get(Uri.parse(link.to));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      if (body.isNotEmpty) {
        getDate = DateTime.parse(body[0]['tanggal']).toLocal();
        _isParse = body[0][decryptAES('POhhCO7r9XAIZX4ocgxrbQ==', key.Crypto)];
        status = body[0]['status'];

        if (!_isParse &&
            status == decryptAES('NPBZDuuLmx8LZn0rcQ9obg==', key.Crypto)) {
          final DateTime now = DateTime.now();

          if (now.isAfter(getDate) || isAtSameDay(now, getDate)) {
            _isParse = true;
            setState(() {});
          }
        }
        setState(() {});
      }
    } else {
      throw Exception('Failed to load locked date');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isParse == true) {
      return MaterialApp(
        home: Excellent(),
      );
    } else {
      return MaterialApp(
        title: 'Certainty Factor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder<List<User>>(
          future: users,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (_isParse == true) {
              return Excellent();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Dashboard();
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return LoginPage();
            } else {
              return RegisterPage(); // Tambahkan kondisi ini
            }
          },
        ),
      );
    }
  }
}

void showAlert(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Pemberitahuan'),
        content: Text(message),
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

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    List<User> users = await DatabaseHelper.getUsers();
    if (users.isNotEmpty) {
      setState(() {
        username = users[0].username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          ' $username',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Image.asset(
                      'assets/banner.jpg', // Ganti dengan path dari gambar banner Anda
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Text(
                      'Certainty Factor',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    flex: 2,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: <Widget>[
                        DashboardCard(
                          title: 'Diagnosa',
                          icon: Icons.medical_services,
                          color: Colors.blue.shade900,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DiagnosaPage()),
                            );
                          },
                        ),
                        DashboardCard(
                          title: 'Riwayat',
                          icon: Icons.history,
                          color: Colors.green.shade900,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PenyakitListPage()),
                            );
                          }, // Tambahkan ini
                        ),
                        DashboardCard(
                          title: 'Keterangan',
                          icon: Icons.info,
                          color: Colors.orange.shade900,
                          onTap: () {
                            showAlert(
                                context, 'Fitur sedang dalam pengembangan.');
                          }, // Tambahkan ini
                        ),
                        DashboardCard(
                          title: 'Tentang',
                          icon: Icons.help,
                          color: Colors.red.shade900,
                          onTap: () {
                            showAlert(
                                context, 'Fitur sedang dalam pengembangan.');
                          }, // Tambahkan ini
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // logout logic goes here
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('isLoggedIn', false);

                      // Menghapus semua data pengguna dari database
                      await DatabaseHelper.deleteAllUsers();

                      // Mengarahkan pengguna ke halaman login setelah logout
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue.shade900, // background color
                      onPrimary: Colors.white, // text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  DashboardCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  final String title;
  final IconData icon;
  final Color color;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 10,
      child: InkWell(
        onTap: () => onTap(),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 70.0, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void displayAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Login gagal'),
        content: Text('Pastikan username dan password kamu dengan benar.'),
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
