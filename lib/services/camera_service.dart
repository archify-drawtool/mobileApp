import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  Future<void> initialize() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) return;

    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );

    await controller!.initialize();
  }

  Future<XFile?> takePhoto() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    return await controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}
