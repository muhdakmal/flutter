import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
  );

  bool isTorchOn = false;

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

  @override
  void dispose() {
    controller.dispose(); // Hentikan scanner sebelum keluar
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
              print("📸 QR Detected!");
              final barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                String? qrValue = barcodes.first.rawValue;
                print('📌 QR Code detected: $qrValue');

                if (qrValue != null && qrValue.isNotEmpty) {
                  // ✅ Tunjuk alert popup
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("QR Code Detected"),
                      content: Text("📌 Data: $qrValue"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup alert
                            Navigator.pop(context, qrValue); // Kembali ke HomePage dengan QR value
                          },
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                } else {
                  print('⚠️ QR code kosong atau tidak boleh dibaca.');
                }
              }
            },
          ),

          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
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
}
