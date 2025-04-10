import 'package:flutter/material.dart';
import 'package:flutter_project/screens/wac_screen.dart';
import 'dart:async';
import 'package:flutter_project/screens/qr_scanner_screen.dart'; // Import QRScannerScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Show the splash screen with an image for 3 seconds before navigating to WACScreen
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WACScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          '../assets/autoCooper_Logo_Color_RGB_old.png',
          width: 300, // Image width
          height: 300, // Image height
        ),
      ),
    );
  }
}
