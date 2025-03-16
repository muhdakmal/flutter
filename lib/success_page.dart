import 'package:flutter/material.dart';
import 'home_page.dart'; // ✅ Import halaman utama

class SuccessPage extends StatelessWidget {
  final String qrValue;
  final double latitude;
  final double longitude;

  SuccessPage({required this.qrValue, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Berjaya!")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("✅ QR Code berjaya disimpan!", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text("📌 QR Value: $qrValue"),
            Text("📍 Lokasi: $latitude, $longitude"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()), // ✅ Pergi ke home_page.dart
                  (Route<dynamic> route) => false, // ❌ Tutup semua page sebelum ini
                );
              },
              child: Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}
