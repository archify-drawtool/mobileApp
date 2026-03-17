import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:archify_app/screens/camera_screen.dart';

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
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final testController = CameraController(
          cameras.first,
          ResolutionPreset.low,
          enableAudio: false,
        );
        await testController.initialize();
        await testController.dispose();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Archify')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Camera toegang vereist',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Archify heeft toegang tot je camera nodig om foto\'s te maken van je toolkit.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
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
