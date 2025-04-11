import 'package:flutter/material.dart';
import 'device_push_screen.dart';
import '../helpers/db_helper.dart'; // Import the DBHelper class

class ScannedWACScreen extends StatefulWidget {
  final String scannedWAC;

  ScannedWACScreen({required this.scannedWAC});

  @override
  _ScannedWACScreenState createState() => _ScannedWACScreenState();
}

bool _isValidIp(String ip) {
  final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$');
  return ipRegex.hasMatch(ip);
}

class _ScannedWACScreenState extends State<ScannedWACScreen> {
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController macAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final scannedData = widget.scannedWAC;
    final macRegex = RegExp(r'MAC:\s*([A-Fa-f0-9:]{17})');
    final match = macRegex.firstMatch(scannedData);

    if (match != null) {
      macAddressController.text = match.group(1)!; // Autofill MAC ID
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid MAC ID')),
      );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanned WAC Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanned WAC: ${widget.scannedWAC}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              errorText: _isValidIp(ipAddressController.text)
                ? null
                : 'Invalid IP Address',
              ),
              onChanged: (value) {
              setState(() {}); // Trigger UI update for validation
              },
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
                // filepath: d:\Flutter\Expeditious-Commissioning\lib\screens\scanned_wac_screen.dart
                ElevatedButton(
                  onPressed: () async {
                    // Collect data from text fields
                    final macId = macAddressController.text;
                    final ipAddress = ipAddressController.text;

                    if (macId.isEmpty || ipAddress.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    // Insert data into the `wacs` table
                    final dbHelper = DBHelper();
                    final wacId = DateTime.now().toIso8601String();
                    await dbHelper.insertWac({
                      'id': wacId,
                      'macid': macId,
                      'ip': ipAddress,
                      'ispushrequired': 0, // Default value for ispushrequired
                    });

                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceListScreen(wacId: wacId),
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
