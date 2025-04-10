import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'wac_screen.dart'; // Make sure to import the necessary WACScreen widget.

class DeviceListScreen extends StatelessWidget {
  // Sample list of Device IDs
  final List<String> deviceIds = [
    'Device 001',
    'Device 002',
    'Device 003',
    'Device 004',
    'Device 005',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScanWacButton(context),
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
      // Navigate to ScannedWACScreen instead of popping back
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
