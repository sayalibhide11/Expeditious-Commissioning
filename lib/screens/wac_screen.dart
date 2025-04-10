import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart'; // Import QRScannerScreen

class WACScreen extends StatelessWidget {
  // Sample list of WACs
  final List<String> wacList = [
    'WAC 001',
    'WAC 002',
    'WAC 003',
    'WAC 004',
    'WAC 005',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WAC List'),
      ),
      body: Column(
        children: [
          // Button at the top-center of the screen
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  // Navigate to QR code scanner screen when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerScreen(),
                    ),
                  );
                },
                child: Text(
                  'Scan WAC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          
          // Text "WAC List" below the button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'WAC List',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // List of WACs below the "WAC List" text
          Expanded(
            child: ListView.builder(
              itemCount: wacList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(wacList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
