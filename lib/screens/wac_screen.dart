// filepath: d:\Flutter\Expeditious-Commissioning\lib\screens\wac_screen.dart
import 'package:flutter/material.dart';
import 'package:Expeditious_Commissioning/screens/device_push_screen.dart';
import '../helpers/db_helper.dart';
import 'code_scanner_screen.dart'; // Import CodeScannerScreen
import 'scanned_wac_screen.dart'; // Import ScannedWACScreen
import 'package:Expeditious_Commissioning/main.dart'; // Import routeObserver

class WACScreen extends StatefulWidget {
  @override
  _WACScreenState createState() => _WACScreenState();
}

class _WACScreenState extends State<WACScreen> with RouteAware {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> wacList = [];

 @override
  void initState() {
    super.initState();
    _fetchWacList();
  }

  @override
    void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      // Register this widget as a RouteAware
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    // Unsubscribe from the RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Called when this route is pushed onto the navigator stack
    super.didPush();
    print('WACScreen: didPush');
  }

  @override
  void didPopNext() {
    // Called when returning to this route from another route
    super.didPopNext();
    print('WACScreen: didPopNext');
    _fetchWacList(); // Refresh the WAC list when returning to this screen
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
        color: Color(0xFF001a72),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
          ),
          child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'WACs',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scan WAC Button
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
                  Icon(Icons.info, color: Color(0xFF001A72)),
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
                    final scannedValue = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CodeScannerScreen()),
                    );

                    if (scannedValue != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) =>
                        ScannedWACScreen(scannedWAC: scannedValue),
                      ),
                    );
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Scan WAC',
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
              height: wacList.isEmpty ? 100 : wacList.length * 72.0, // Adjust height dynamically
              child: Center(
                child: wacList.isEmpty
                  ? const Center(
                  child: Text(
                  'No WACs available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  )
                  : ListView.builder(
                  itemCount: wacList.length,
                  itemBuilder: (context, index) {
                  final wac = wacList[index];
                  bool isChecked = false; // Track checkbox state
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: ListTile(
                    // leading: StatefulBuilder(
                    // builder: (context, setState) {
                    //   return Checkbox(
                    //   value: isChecked,
                    //   checkColor: Colors.white,
                    //   activeColor: Color(0xFF001a72),
                    //   onChanged: (bool? value) {
                    //   setState(() {
                    //   isChecked = value ?? false;
                    //   });
                    //   },
                    //   );
                    // },
                    // ),
                    title: Text(
                    wac['mac_id'] ?? 'No MAC ID',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                    wac['ip_address'] ?? 'No IP Address',
                    style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () async {
                    await dbHelper.deleteWac(wac['mac_id']);
                    _fetchWacList();
                    },
                    ),
                    onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceListScreen(
                      wacId: wac['mac_id'],
                      ),
                    ),
                    );
                    },
                    ),
                  );
                  },
                  ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}