import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // ✅ Gambar & Nama Pengguna
          Container(
            color: Colors.grey,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/profile.jpg"), // Tukar gambar
                ),
                SizedBox(height: 10),
                Text(
                  "Encik Muhammad Akmal bin Abu Bakar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "Bahagian Teknologi Maklumat dan Komunikasi",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ✅ Menu Pilihan
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title: Text("My Profile"),
            onTap: () {
              // Tambah navigasi ke Profile Page
            },
          ),
          ListTile(
            leading: Icon(Icons.qr_code, color: Colors.green),
            title: Text("QR Record History"),
            onTap: () {
              // Tambah navigasi ke QR Page
            },
          ),
          ListTile(
            leading: Icon(Icons.local_hospital, color: Colors.red),
            title: Text("Clinics & Hospital Panel"),
            onTap: () {
              // Tambah navigasi ke Clinics Page
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.orange),
            title: Text("Log Out"),
            onTap: () {
              // Tambah fungsi log out
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.purple),
            title: Text("About this app"),
            onTap: () {
              // Tambah navigasi ke About Page
            },
          ),
        ],
      ),
    );
  }
}
