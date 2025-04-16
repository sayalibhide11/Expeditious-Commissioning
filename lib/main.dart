import 'dart:io';

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/wac_screen.dart'; // Import your WACScreen

// Declare the RouteObserver globally
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  HttpOverrides.global = CAHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver], // Add the RouteObserver here
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class CAHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}