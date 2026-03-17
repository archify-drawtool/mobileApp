import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

class CameraDeniedScreen extends StatelessWidget {
  const CameraDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archify'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                color: AppColors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Geen Camera toegang',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Camera toegang is geweigerd. Pas dit aan in je instellingen om Archify te gebruiken.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => AppSettings.openAppSettings(),
                child: const Text('Instellingen openen'),
              ),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
