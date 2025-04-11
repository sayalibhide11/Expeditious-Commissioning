import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
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
            .map((mapping) => mapping['device_ids'] as String)
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
              children: [_buildScanWacButton(context), _buildDeleteAllButton()],
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

  // Button to navigate to the QR Scanner screen
  Widget _buildScanWacButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final scannedValue = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRScannerScreen()),
        );

        if (scannedValue != null) {
          final dbHelper = DBHelper();
          final deviceId = DateTime.now().toIso8601String(); // Generate a unique device ID
          await dbHelper.insertDevice({
            'id': deviceId,
            'macid': scannedValue, // Use the scanned value
          });
          await dbHelper.insertWacDeviceMapping({
            'wacids': widget.wacId,
            'device_ids': deviceId,
          });

          // Refresh the device list
          _fetchDeviceList();
        }
      },
      child: const Text('Scan Device'),
    );
  }

  // Button to delete all devices
  Widget _buildDeleteAllButton() {
    return ElevatedButton(
      onPressed: () async {
        // Delete all entries in the WAC table
        await dbHelper.deleteAllDevices();
        _fetchDeviceList(); // Refresh the list
      },
      child: const Text('Delete All Devices'),
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
            title: Text(device['macid'] ?? 'No MAC ID'), // Display the MAC ID
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
      children: [_buildBackButton(context), _buildPushButton()],
    );
  }

  // Back button: Navigate to WACScreen
  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate back to WACScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WACScreen(), // Navigates to WACScreen
          ),
        );
      },
      child: const Text('Back'),
    );
  }

  // Push button: You can define the action you want here (e.g., saving data)
  Widget _buildPushButton() {
    return ElevatedButton(
      onPressed: () {
        // Perform action on Push (e.g., save data)
        debugPrint('Push button clicked');
      },
      child: const Text('Push'),
    );
  }
}
