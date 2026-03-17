import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Geen camera gevonden');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Camera fout: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(child: Text(_error!)),
      );
    }

    if (!_isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Richt op de toolkit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final photo = await picker.pickImage(source: ImageSource.gallery);
                  if (photo != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoPreviewScreen(photoPath: photo.path),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 32),
              FloatingActionButton(
                onPressed: () async {
                  final photo = await _controller!.takePicture();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoPreviewScreen(photoPath: photo.path),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.camera_alt),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
