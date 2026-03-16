import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:archify_app/services/camera_service.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    await _cameraService.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onTakePhoto() async {
    final photo = await _cameraService.takePhoto();
    if (photo == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreviewScreen(photoPath: photo.path),
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: CameraPreview(_cameraService.controller!),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: const Text(
              'Richt op de toolkit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _onTakePhoto,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
