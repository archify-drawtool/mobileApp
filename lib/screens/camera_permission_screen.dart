import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';
import 'package:archify_app/screens/camera_screen.dart';

class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({super.key});

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery);

    if (photo != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(photoPath: photo.path),
        ),
      );
    }
  }

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
              const Icon(Icons.camera_alt_outlined, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Foto maken of kiezen',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Foto maken'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
