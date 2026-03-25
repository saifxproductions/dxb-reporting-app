import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/create_report_screen.dart';

void main() {
  runApp(const DxbReportingApp());
}

class DxbReportingApp extends StatelessWidget {
  const DxbReportingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DXB Reporting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BFA5)),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const CreateReportScreen(),
    );
  }
}
