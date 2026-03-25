import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archify_app/screens/camera_screen.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPermissionScreen = prefs.getBool('hasSeenPermissionScreen') ?? false;

    if (hasSeenPermissionScreen && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
      return;
    }

    if (mounted) {
      setState(() => _checking = false);
    }
  }

  Future<void> _onAllowAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenPermissionScreen', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.magenta),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const ArchifyLogo()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.camera,
                color: AppColors.white,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera toegang vereist',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 12),
              const Text(
                'Archify heeft toegang tot je camera nodig om foto\'s te maken van je toolkit.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onAllowAccess,
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
