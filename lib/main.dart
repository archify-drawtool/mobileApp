import 'package:flutter/material.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

void main() {
  runApp(const ArchifyApp());
}

class ArchifyApp extends StatelessWidget {
  const ArchifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archify',
      theme: AppTheme.theme,
      home: const CameraPermissionScreen(),
    );
  }
}
