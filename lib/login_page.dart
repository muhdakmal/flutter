import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // ⏳ State untuk loading indicator

  Future<void> login() async {
    setState(() {
      isLoading = true; // Mula loading
    });

    try {
      var dio = Dio();
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      var response = await dio.post(
        "https://sun-alaska-movies-photo.trycloudflare.com/flutter-api/login.php",
        data: {
          "username": usernameController.text,
          "password": passwordController.text,
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Raw Response Body: ${response.data}");

      // ✅ Paksa decode sebagai Map (kalau response masih dalam String)
      var responseData = response.data;
      if (responseData is String) {
        responseData = json.decode(responseData); // Decode jika masih String
      }

      print("Decoded Response: $responseData");

      if (responseData["status"] == "success") {

      String username = usernameController.text;
  await _saveUsername(username); // Simpan username sebelum navigate

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"] ?? "Ralat tidak diketahui")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal. Sila cuba lagi!")),
      );
    } finally {
      setState(() {
        isLoading = false; // Tamat loading
      });
    }
  }

  Future<void> _saveUsername(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("username", username);
  print("Username disimpan: $username"); // Debugging
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Logo Bulat dengan Border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue, // Warna border
                    width: 2, // Ketebalan border
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/splash.png"),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: 20),

              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login, // Disable button masa loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white) // ⏳ Loader
                      : Text(
                          "Login",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              SizedBox(height: 15),

              TextButton(
                onPressed: isLoading ? null : () {
                  // Handle register nanti
                },
                child: Text("Belum ada akaun? Daftar di sini"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
