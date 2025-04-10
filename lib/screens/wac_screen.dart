// filepath: d:\Flutter\Expeditious-Commissioning\lib\screens\wac_screen.dart
import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import 'qr_scanner_screen.dart'; // Import QRScannerScreen

class WACScreen extends StatefulWidget {
  @override
  _WACScreenState createState() => _WACScreenState();
}

class _WACScreenState extends State<WACScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> wacList = [];

  @override
  void initState() {
    super.initState();
    _fetchWacList();
  }

  Future<void> _fetchWacList() async {
    final data = await dbHelper.getWacs();
    setState(() {
      wacList = data;
    });
  }

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

          // Button to delete all WACs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () async {
                  // Delete all entries in the WAC table
                  await dbHelper.deleteAllWacs();
                  _fetchWacList(); // Refresh the list
                },
                child: Text(
                  'Delete All WACs',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 31, 30, 30),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // List of WACs below the "WAC List" text
          Expanded(
            child: ListView.builder(
              itemCount: wacList.length,
              itemBuilder: (context, index) {
                final wac = wacList[index];
                return ListTile(
                  title: Text(wac['macid']), // Display MAC ID
                  subtitle: Text(wac['ip']), // Display IP Address
                  trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Delete the specific WAC entry
                    await dbHelper.deleteWac(wac['id']);
                    _fetchWacList(); // Refresh the list
                  },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}