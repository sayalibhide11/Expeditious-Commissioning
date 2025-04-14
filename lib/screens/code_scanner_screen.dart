import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CodeScannerScreen(),
    );
  }
}

class CodeScannerScreen extends StatefulWidget {
  const CodeScannerScreen({super.key});

  @override
  State<CodeScannerScreen> createState() => _CodeScannerScreenState();
}

class _CodeScannerScreenState extends State<CodeScannerScreen> {
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
    final BarcodeFormat? format = barcode.format;

    if (rawValue != null && rawValue.isNotEmpty) {
      setState(() {
        _isScanCompleted = true;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Square with rounded edges
          ),
          title: const Text("Barcode Scanned"),
          content: Text('Value: $rawValue\nFormat: $format'),
          actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          SizedBox(
            width: 100, // Set a fixed width for both buttons
            child: TextButton(
              style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Square with rounded edges
              side: const BorderSide(color: Color.fromARGB(255, 196, 194, 194)), // Grey outline
            ),
              ),
              onPressed: () {
            Navigator.pop(context);
            setState(() => _isScanCompleted = false);
              },
              child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontSize: 12), // Decreased font size
              ),
            ),
          ),
          SizedBox(
            width: 100, // Set a fixed width for both buttons
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF001a72), // #001a72 background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Square with rounded edges
            ),
              ),
              onPressed: () {
            Navigator.pop(context); // Close the dialog
            Navigator.pop(
              context,
              rawValue,
            ); // Return the scanned value
              },
              child: const Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: 12), // Decreased font size
              ),
            ),
          ),
            ],
          ),
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
        title: const Text('Scan Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.torchState,
              builder: (context, torchState, child) {
                return Icon(
                  torchState == TorchState.on
                      ? Icons
                          .flash_on // Hex code: 0xe3b0
                      : Icons.flash_off, // Hex code: 0xe3b1
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetection),
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(width: 40, height: 5, color: Colors.grey),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(width: 5, height: 40, color: Colors.grey),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(width: 40, height: 5, color: Colors.grey),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(width: 5, height: 40, color: Colors.grey),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(width: 40, height: 5, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(width: 5, height: 40, color: Colors.grey),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(width: 40, height: 5, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(width: 5, height: 40, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
