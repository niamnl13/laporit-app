import 'package:flutter/material.dart';
import 'package:laporit_app/core/router/app_router.dart';
import 'package:laporit_app/features/auth/login.dart';
import 'package:laporit_app/features/user/dashboard_user.dart';
import 'package:laporit_app/features/user/add_laporan_baru.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor IT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const LoginScreen(),
    );
  }
}