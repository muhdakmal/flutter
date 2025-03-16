import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'qr_scanner_screen.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = "Loading...";
  String? _usernameLogin;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _getSavedUsername();
  }

  Future<void> _getSavedUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString("username");

    if (username != null) {
      setState(() {
        _usernameLogin = username;
      });

      _fetchUserName(username);
    }
  }

  Future<void> _fetchUserName(String username) async {
    try {
      String url =
          'https://sun-alaska-movies-photo.trycloudflare.com/flutter-api/get_user.php?username=${Uri.encodeComponent(username)}';

      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.data.toString());

        if (data['status'] == "success") {
          setState(() {
            _userName = data['name'];
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  List<Widget> get _pages => [
        HomeScreen(userName: _userName), // ✅ Hantar userName ke HomeScreen
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

class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Dio dio = Dio();
  String? _attendanceStatus;
  String? _usernameLogin;

  @override
  void initState() {
    super.initState();
    _getSavedUsername();
  }

  Future<void> _getSavedUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString("username");

    if (username != null) {
      setState(() {
        _usernameLogin = username;
      });

      _fetchAttendanceStatus(username);
    }
  }

  Future<void> _fetchAttendanceStatus(String username) async {
    try {
      String url =
          'https://sun-alaska-movies-photo.trycloudflare.com/flutter-api/get_attendance.php?username=${Uri.encodeComponent(username)}';

      Response response = await dio.get(url);
      var data = response.data;

      if (data is String) {
        data = jsonDecode(data);
      }

      if (data['status'] == "success") {
        setState(() {
          _attendanceStatus = data['check_in'];
        });
      } else {
        setState(() {
          _attendanceStatus = "Belum Check-In";
        });
      }
    } catch (e) {
      print("⚠️ Error fetching attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_usernameLogin != null) {
          await _fetchAttendanceStatus(_usernameLogin!);
        }
      },
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
                SizedBox(height: 20),
                Text(
                  "Status Kehadiran: ${_attendanceStatus ?? "Loading..."}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
