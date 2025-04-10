import 'package:flutter/material.dart';
import 'device_push_screen.dart';

class ScannedWACScreen extends StatefulWidget {
  final String scannedWAC;

  ScannedWACScreen({required this.scannedWAC});

  @override
  _ScannedWACScreenState createState() => _ScannedWACScreenState();
}

class _ScannedWACScreenState extends State<ScannedWACScreen> {
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController macAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    macAddressController.text = "00:11:22:33:44:55"; // Example MAC address
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned WAC Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanned WAC: ${widget.scannedWAC}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: macAddressController,
              decoration: InputDecoration(
                labelText: 'MAC ID',
                border: OutlineInputBorder(),
              ),
              enabled: false, // Disable the MAC ID field
            ),
            SizedBox(height: 20),
            TextField(
              controller: ipAddressController,
              decoration: InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to DeviceListScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceListScreen(),
                      ),
                    );
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
