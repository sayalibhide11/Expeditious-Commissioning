import 'dart:ffi';
import 'package:flutter/material.dart';
import 'code_scanner_screen.dart';
import 'wac_screen.dart'; // Make sure to import the necessary WACScreen widget.
import 'dart:convert'; // Import for jsonEncode
import 'package:http/http.dart' as http; // Import the http package
import '../helpers/db_helper.dart'; // Import the DBHelper class.

class DeviceListScreen extends StatefulWidget {
  final String wacId;
  DeviceListScreen({required this.wacId});
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final DBHelper dbHelper = DBHelper();

  List<Map<String, dynamic>> deviceList = [];

  @override
  void initState() {
    super.initState();
    _fetchDeviceList();
  }

  Future<void> _fetchDeviceList() async {
    final wacDeviceMappings = await dbHelper.getWacDeviceMappings(widget.wacId);
    final deviceIds =
        wacDeviceMappings.map((mapping) => mapping['device_id'] as String).toList();
    final data = await dbHelper.getDevicesByIds(deviceIds);

    setState(() {
      deviceList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF001a72),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WACScreen()),
              (route) => false, // Remove all previous routes
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: dbHelper.getWacDetails(widget.wacId), // Fetch WAC details
              builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!['ip_address'] == null) {
                return const Text(
                'WAC IP Address: Not available',
                style: TextStyle(fontSize: 16, color: Colors.red),
                );
              } else {
                final ipAddress = snapshot.data!['ip_address'];
                return Container(
                margin: const EdgeInsets.only(bottom: 4), // Add 4px margin at the bottom
                child: Text(
                  'WAC IP Address: $ipAddress',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                );
              }
              },
            ),
            
            // First card with Scan Device button and info icon
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                         Icon(Icons.info, color: Color(0xFF001A72), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Scan QR Code to add WAC',
                          style: TextStyle(
                            color: Color(0xFF001A72),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity, // Set width to 100%
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001A72),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded edges
                          ),
                        ),
                        onPressed: () async {
                          var scannedValue = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CodeScannerScreen()),
                          );

                          if (scannedValue != null) {
                            scannedValue = scannedValue.replaceAll(':', '').toLowerCase();
                            final result = await dbHelper.insertDevice({'mac_id': scannedValue});
                            if (result == 0) {
                              print('Device already exists in the database.');
                            } else {
                              print('Device inserted successfully.');
}
                            await dbHelper.insertWacDeviceMapping({
                              'wac_id': widget.wacId,
                              'device_id': scannedValue,
                            });

                            await dbHelper.updateWacPushRequired(widget.wacId, 0);
                            _fetchDeviceList();
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                        label: const Text(
                          'Scan Device',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: SizedBox(
                height: deviceList.isEmpty ? 100 : deviceList.length * 56.0,
                child: Center(
                  child: deviceList.isEmpty
                      ? const Center(
                          child: Text(
                            'No Devices available.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: deviceList.length,
                          itemBuilder: (context, index) {
                            final device = deviceList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: ListTile(
                                title: Text(
                                  device['mac_id'] ?? 'No MAC ID',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await dbHelper.deleteDevice(device['mac_id']);
                                    _fetchDeviceList();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _buildPushButton(), // Add the button to the bottom right
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPushButton() {
    return FutureBuilder<int>(
      future: dbHelper.getWacPushRequired(
        widget.wacId,
      ), // Fetch is_push_required value
      builder: (context, snapshot) {


        final isPushRequired =
            snapshot.data == 0 && deviceList.isNotEmpty; // Enable if is_push_required is 0 and deviceList is not empty

        return FloatingActionButton.extended(
            onPressed: isPushRequired
              ? () async {
                // Fetch the IP address of the WAC from the database
                final wacDetails = await dbHelper.getWacDetails(widget.wacId);
                final ipAddress = wacDetails['ip_address'];

                if (ipAddress == null || ipAddress.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('WAC IP address not found')),
                );
                return;
                }

                // Prepare the API body
                final List<String> macIds = deviceList
                  .map((device) => device['mac_id'] as String)
                  .toList();

                final url = Uri.parse('https://$ipAddress/v2/devicesToPair');
                final body = {
                  'eui64List': macIds.map((macId) => macId).toList(),
                };

                try {
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(body),
                );

                if (response.statusCode == 200) {
                  // Update is_push_required to 1 in the database
                  await dbHelper.updateWacPushRequired(widget.wacId, 1);
                  setState(() {}); // Refresh the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Devices pushed successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to push devices: ${response.body}')),
                  );
                }
                } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
                }
              }
              : null, // Disable button if is_push_required is 1
            label: const Text('Push'),
            icon: const Icon(Icons.cloud_upload),
            backgroundColor: isPushRequired ? const Color(0xFF001A72) : Colors.grey,
            foregroundColor: isPushRequired ? Colors.white : Colors.black,
        );
      },
    );
  }
}
