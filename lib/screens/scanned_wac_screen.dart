import 'package:flutter/material.dart';
import 'device_push_screen.dart';
import '../helpers/db_helper.dart'; // Import the DBHelper class

class ScannedWACScreen extends StatefulWidget {
  final String scannedWAC;

  const ScannedWACScreen({super.key, required this.scannedWAC});

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
    final macRegex = RegExp(r'([A-Fa-f0-9:]{17})');
    final match = macRegex.firstMatch(scannedData);

    if (match != null) {
      final rawMacId = match.group(1)!;
      final formattedMacId = rawMacId.replaceAll(':', '').toLowerCase();
      macAddressController.text = formattedMacId; // Autofill formatted MAC ID
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
      appBar: AppBar(
        title: Text(
        'Add WAC',
        style: TextStyle(color: Colors.white), // Set title color to white
      ),
        backgroundColor: Color(0xFF001a72), // Same format as Save button
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Spacer(), // Push buttons to the bottom
            // Divider(
            //   color: Colors.grey, // Grey color for the border line
            //   thickness: 1, // Adjust thickness for better visibility
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey), // Grey outline
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded edges
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black), // Black text
                  ),
                ),
                SizedBox(width: 10), // Add spacing between buttons
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
                    try {
                      await dbHelper.insertWac({
                      'mac_id': macId,
                      'ip_address': ipAddress,
                      'is_push_required': 0, // Default value for is_push_required
                      });
                    } catch (e) {
                      if (e.toString().contains('UNIQUE constraint failed')) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('This WAC is already added.'),
                        actions: [
                          TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                          ),
                        ],
                        ),
                      );
                      } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An unexpected error occurred')),
                      );
                      }
                      return;
                    }

                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceListScreen(wacId: macId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF001a72), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded edges
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white), // White text
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
