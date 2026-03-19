import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/screens/camera_screen.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';

class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ArchifyLogo()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.camera,
                color: AppColors.white,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera toegang vereist',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Archify heeft toegang tot je camera nodig om foto\'s te maken van je toolkit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    );
                  },
                  child: const Text('Toegang toestaan'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera toegang is nodig om Archify te gebruiken')),
                  );
                },
                child: const Text('Niet nu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
