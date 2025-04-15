import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/wac_screen.dart'; // Import your WACScreen

// Declare the RouteObserver globally
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
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