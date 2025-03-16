import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'qr_scanner_screen.dart';
import 'settings_page.dart';
import 'dart:convert'; // ✅ Tambah import ini untuk JSON decoding
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Simpan nama user
  String _userName = "Loading...";
  String? _usernameLogin; // ✅ Simpan username login
  Dio dio = Dio();

   @override
  void initState() {
    super.initState();
    _getSavedUsername(); // ✅ Ambil username dari SharedPreferences
  }

  Future<void> _getSavedUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString("username"); // ✅ Ambil dari storage

  if (username != null) {
    print("Username dari sesi: $username"); // Debugging
    setState(() {
      _usernameLogin = username;
    });

    _fetchUserName(username); // ✅ Panggil API dengan username
  } else {
    print("Tiada username dalam sesi! Pengguna belum login.");
    // Boleh redirect ke login page jika perlu
  }
}



  Future<void> _fetchUserName(String username) async {
  try {
    String url = 'https://explicitly-pipeline-mo-atlas.trycloudflare.com/flutter-api/get_user.php?username=${Uri.encodeComponent(username)}';
    print("Fetching from: $url"); // ✅ Debug URL API

    Response response = await dio.get(url);

    print("Response status: ${response.statusCode}"); // ✅ Debug HTTP status

    print("Raw response: ${response.data}"); // ✅ Debug full response

    if (response.statusCode == 200) {
      var data = jsonDecode(response.data.toString()); // ✅ Decode JSON

      print("Decoded data: $data"); // ✅ Debug JSON data

      if (data['status'] == "success") { 
        setState(() {
          _userName = data['name']; // ✅ Update UI
        });
      } else {
        print("API error: ${data['message']}"); // ✅ Debug jika status bukan success
      }
    }
  } catch (e) {
    print("Error fetching data: $e"); // ✅ Tangkap error jika ada
  }
}



  // List halaman
  List<Widget> get _pages => [
        HomeScreen(userName: _userName),
        QRScannerScreen(),
        SettingsPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_selectedIndex == 0 || _selectedIndex == 2)
            Column(
              children: [
                AppBar(title: Center(child: Text("my APP"))),
                Expanded(child: _pages[_selectedIndex]),
              ],
            )
          else
            _pages[_selectedIndex],

          if (_selectedIndex == 1)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                color: Colors.black.withOpacity(0.5),
                child: SafeArea(
                  child: Text(
                    "my APP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Scan QR"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Halaman HomeScreen dengan User Name
class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshPage() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: ListView(
        children: [
          SizedBox(height: 50),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                SizedBox(height: 10),
                Text(
                  "Selamat Datang, ${widget.userName}!", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
