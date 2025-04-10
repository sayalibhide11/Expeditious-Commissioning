import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'wac_screen.dart'; // Make sure to import the necessary WACScreen widget.

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  // Sample list of Device IDs
  List<String> deviceIds = [
    'Device 001',
    'Device 002',
    'Device 003',
    'Device 004',
    'Device 005',
  ];

  // Function to delete all devices
  void _deleteAllDevices() {
    setState(() {
      deviceIds.clear(); // Clear all items in the list
    });
  }

  // Function to delete a single device by index
  void _deleteDevice(int index) {
    setState(() {
      deviceIds.removeAt(index); // Remove device at given index
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
              children: [
                _buildScanWacButton(context),
                _buildDeleteAllButton(),
              ],
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
    return AppBar(
      title: const Text('Device List'),
    );
  }

  // Button to navigate to the QR Scanner screen
  Widget _buildScanWacButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to QRScannerScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRScannerScreen(),
          ),
        );
      },
      child: const Text('Scan Device'),
    );
  }

  // Button to delete all devices
  Widget _buildDeleteAllButton() {
    return ElevatedButton(
      onPressed: _deleteAllDevices,
      child: const Text('Delete All Devices'),
    );
  }

  // Title for the device list
  Widget _buildDeviceListTitle() {
    return const Text(
      'Device List:',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // List of device IDs
  Widget _buildDeviceList() {
    return Expanded(
      child: ListView.builder(
        itemCount: deviceIds.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(deviceIds[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteDevice(index), // Delete individual device
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
      children: [
        _buildBackButton(context),
        _buildPushButton(),
      ],
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
