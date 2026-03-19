import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/screens/photo_preview_screen.dart';
import 'package:archify_app/screens/camera_denied_screen.dart';
import 'package:archify_app/theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isReady = false;
  bool _isNavigating = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isNavigating || _isInitializing) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_isReady) {
        _controller?.dispose();
        _controller = null;
        setState(() => _isReady = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_isReady) {
        _initCamera();
      }
    }
  }

  Future<void> _initCamera() async {
    if (_isNavigating || _isInitializing) return;
    _isInitializing = true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted && !_isNavigating) {
          _isNavigating = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CameraDeniedScreen()),
          );
        }
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted && !_isNavigating) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CameraDeniedScreen()),
        );
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _onTakePhoto() async {
    final photo = await _controller!.takePicture();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(photoPath: photo.path),
        ),
      );
    }
  }

  Future<void> _onPickFromGallery() async {
    final photo = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (photo != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(photoPath: photo.path),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.magenta),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archify'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.magenta, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'CAMERA',
              style: TextStyle(
                color: AppColors.magenta,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Richt op de toolkit',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.magenta, width: 2),
                ),
                child: ClipRect(
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: GestureDetector(
                      onTap: _onPickFromGallery,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.image,
                          color: AppColors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _onTakePhoto,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.magenta,
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
