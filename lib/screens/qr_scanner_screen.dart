import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scanned_wac_screen.dart'; // You'll create this next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRScannerScreen(),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );

  bool _isScanCompleted = false;

  void _handleDetection(BarcodeCapture capture) {
    if (_isScanCompleted) return;

    final Barcode barcode = capture.barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue != null && rawValue.isNotEmpty) {
      setState(() {
        _isScanCompleted = true;
      });

      print('Scanned: $rawValue');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("QR Code Scanned"),
          content: Text(rawValue),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isScanCompleted = false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScannedWACScreen(scannedWAC: rawValue),
                  ),
                ).then((_) {
                  setState(() => _isScanCompleted = false);
                });
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.torchState,
              builder: (context, torchState, child) {
                return Icon(
                  torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
