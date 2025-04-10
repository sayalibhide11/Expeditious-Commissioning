import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scanned_wac_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRScannerScreen(),
    );
  }
}

// QRScannerScreen - To scan the QR code
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // Controller for QR code scanner
  final GlobalKey qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (BarcodeCapture barcode) {
                if (barcode.barcodes.isNotEmpty) {
                  final String code = barcode.barcodes.first.rawValue ?? "Unknown";
                  // Navigate to the next screen with the scanned WAC code
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScannedWACScreen(scannedWAC: code),
                    ),
                  );
                } else {
                  print("Failed to scan QR Code");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}