import 'package:flutter/material.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';

void main() {
  runApp(const ArchifyApp());
}

class ArchifyApp extends StatelessWidget {
  const ArchifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const CameraPermissionScreen(),
    );
  }
}
