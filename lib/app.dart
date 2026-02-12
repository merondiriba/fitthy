import 'package:flutter/material.dart';

import 'features/stretching/presentation/screens/session_screen.dart';

class StretchApp extends StatelessWidget {
  const StretchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stretching',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SessionScreen(),
    );
  }
}