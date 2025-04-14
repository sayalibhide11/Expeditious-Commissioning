import 'package:flutter/material.dart';
import 'code_scanner_screen.dart';
import 'wac_screen.dart'; // Make sure to import the necessary WACScreen widget.
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
    // Fetch device IDs associated with the current WAC ID
    final wacDeviceMappings = await dbHelper.getWacDeviceMappings(widget.wacId);
    final deviceIds =
        wacDeviceMappings
            .map((mapping) => mapping['device_id'] as String)
            .toList();
    // Fetch devices matching the retrieved device IDs
    final data = await dbHelper.getDevicesByIds(deviceIds);

    setState(() {
      deviceList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add both buttons here (Scan and Delete All)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildScanWacButton(context)],
            ),
            const SizedBox(height: 20),
            _buildDeviceListTitle(),
            const SizedBox(height: 10),
            _buildDeviceList(),
            const SizedBox(height: 20), // Space between list and buttons
            const Spacer(), // Ensures the buttons are at the bottom
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // AppBar widget
  PreferredSizeWidget _buildAppBar() {
    return AppBar(title: const Text('Device List'));
  }

  // Button to navigate to the Code Scanner screen
  Widget _buildScanWacButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final scannedValue = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CodeScannerScreen()),
        );

        if (scannedValue != null) {
          final dbHelper = DBHelper();
          await dbHelper.insertDevice({
            'mac_id': scannedValue, // Use the scanned value
          });
          await dbHelper.insertWacDeviceMapping({
            'wac_id': widget.wacId,
            'device_id': scannedValue,
          });

          await dbHelper.updateWacPushRequired(widget.wacId, 0); // Set is_push_required to 0

          // Refresh the device list
          _fetchDeviceList();
        }
      },
      child: const Text('Scan Device'),
    );
  }

  // Title for the device list
  Widget _buildDeviceListTitle() {
    return const Text(
      'Device List:',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  // List of device IDs
  Widget _buildDeviceList() {
    return Expanded(
      child: ListView.builder(
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          final device =
              deviceList[index]; // Extract the map for the current device
          return ListTile(
            title: Text(device['mac_id'] ?? 'No MAC ID'), // Display the MAC ID
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await dbHelper.deleteDevice(
                  device['id'],
                ); // Delete the device by ID
                _fetchDeviceList(); // Refresh the list after deletion
              },
            ),
          );
        },
      ),
    );
  }

  // Row containing action buttons (Back and Push)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildPushButton()],
    );
  }

  Widget _buildPushButton() {
    return FutureBuilder<int>(
      future: dbHelper.getWacPushRequired(
        widget.wacId,
      ), // Fetch is_push_required value
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ElevatedButton(
            onPressed: null, // Disable button while loading
            child: const Text('Push'),
          );
        }

        final isPushRequired =
            snapshot.data == 0; // Enable if is_push_required is 0

        return ElevatedButton(
          onPressed:
              isPushRequired
                  ? () async {
                    // Perform action on Push
                    await dbHelper.updateWacPushRequired(
                      widget.wacId,
                      1,
                    ); // Set is_push_required to 1
                    setState(() {}); // Refresh the UI
                  }
                  : null, // Disable button if is_push_required is 1
          child: const Text('Push'),
        );
      },
    );
  }
}
