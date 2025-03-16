import 'package:flutter/material.dart';
import 'home_page.dart'; // ✅ Import halaman utama

class FailedPage extends StatelessWidget {
  final String errorMessage;

  FailedPage({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gagal")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 100),
            SizedBox(height: 20),
            Text("❌ Gagal menyimpan QR!", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}
