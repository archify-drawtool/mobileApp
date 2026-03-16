import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:archify_app/screens/camera_screen.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  bool _denied = false;

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();

    if (!mounted) return;

    if (status.isGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
    } else {
      setState(() {
        _denied = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_denied) {
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
                  onPressed: () => openAppSettings(),
                  child: const Text('Instellingen openen'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _denied = false;
                    });
                  },
                  child: const Text('Probeer opnieuw'),
                ),
              ],
            ),
          ),
        ),
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
                onPressed: _requestPermission,
                child: const Text('Toegang toestaan'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Niet nu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
