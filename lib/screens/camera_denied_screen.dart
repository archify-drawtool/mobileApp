import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';

class CameraDeniedScreen extends StatelessWidget {
  const CameraDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archify')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Geen camera toegang',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Camera toegang is geweigerd. Pas dit aan in je instellingen om Archify te gebruiken.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => AppSettings.openAppSettings(),
                child: const Text('Instellingen openen'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraPermissionScreen(),
                    ),
                  );
                },
                child: const Text('Probeer opnieuw'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
