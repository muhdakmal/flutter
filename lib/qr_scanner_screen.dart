import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'success_page.dart'; // ✅ Page baru jika berjaya insert
import 'failed_page.dart'; // ✅ Page baru jika berjaya insert
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
  );

  Dio dio = Dio();
  bool isTorchOn = false;
  bool isProcessing = false;

  void pickImageFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      print("📷 File dipilih: ${file.path}");
    }
  }

  void toggleFlash() {
    setState(() {
      isTorchOn = !isTorchOn;
    });
    controller.toggleTorch();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("⚠️ Servis lokasi tidak diaktifkan!");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Pengguna menolak akses lokasi");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ Akses lokasi ditolak selama-lamanya!");
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showLoadingDialog() {
  showDialog(
    context: context,
    barrierDismissible: false, // ❌ Jangan bagi tutup dialog semasa loading
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(), // ✅ Tunjuk loading
          SizedBox(height: 10),
          Text("Sedang memproses..."),
        ],
      ),
    ),
  );
}

void _showNotification(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}



  Future<void> _insertQRtoDatabase(String qrValue) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      Position? position = await _getCurrentLocation();
      if (position == null) {
        print("⚠️ Lokasi tidak dapat dikesan.");
        return;
      }

      double latitude = position.latitude;
      double longitude = position.longitude;

      // 🔹 Debug: Cetak data sebelum hantar ke server
      print("📤 Menghantar data ke server: QR = $qrValue, Latitude = $latitude, Longitude = $longitude");

      var response = await dio.post(
        "https://sun-alaska-movies-photo.trycloudflare.com/flutter-api/insert_qr.php",
        data: {
          "qr_value": qrValue,
          "latitude": latitude.toString(),
          "longitude": longitude.toString(),
        },
      );

      // 🔹 Debug: Cetak response dari server
      print("🔄 Response dari server: ${response.data}");

      var responseData = response.data;
      if (responseData is String) {
        responseData = json.decode(responseData);
      }

      String message = responseData["message"] ?? "Tiada mesej dari server";

      if (responseData["status"] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(qrValue: qrValue, latitude: latitude, longitude: longitude),
          ),
        );
      } else {
        //_showNotification(message); // ✅ Paparkan notifikasi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FailedPage(errorMessage: message),
        ),
      );
      }
    } catch (e) {
      print("⚠️ Error: $e");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!isProcessing) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  String? qrValue = barcodes.first.rawValue;
                  if (qrValue != null && qrValue.isNotEmpty) {
                    _showConfirmationDialog(qrValue);
                  }
                }
              }
            },
          ),
          Center(
  child: Column(
    mainAxisSize: MainAxisSize.min, // Supaya column hanya guna ruang yang perlu
    children: [
      Text(
        "Place QR in the scan area",
        style: TextStyle(
          color: Colors.white, // Warna teks putih
          fontSize: 16, // Saiz teks
          fontWeight: FontWeight.bold, // Tebalkan teks
        ),
      ),
      SizedBox(height: 10), // Jarak antara teks dan kotak merah
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ],
  ),
),


          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.image, size: 40, color: Colors.white),
                  onPressed: pickImageFromFile,
                ),
                IconButton(
                  icon: Icon(
                    isTorchOn ? Icons.flash_on : Icons.flash_off,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: toggleFlash,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 void _showConfirmationDialog(String qrValue) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text("Confirm Insert"),
      content: Text("Adakah anda ingin simpan data ini?\n\n📌 $qrValue"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Tutup dialog
          },
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Tutup dialog confirm
            _showLoadingDialog(); // ✅ Tunjuk loading dulu
            _insertQRtoDatabase(qrValue); // ✅ Mulakan proses insert
          },
          child: Text("Yes"),
        ),
      ],
    ),
  );
}

}
