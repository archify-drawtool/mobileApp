import 'dart:async';
import 'package:archify_app/main.dart';
import 'package:archify_app/screens/project_selection_screen.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/photo_service.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/photo_preview_box.dart';
import 'package:archify_app/widgets/screen_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PhotoReviewScreen extends StatefulWidget {
  final String photoPath;

  const PhotoReviewScreen({super.key, required this.photoPath});

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {
  static const _pollInterval = Duration(milliseconds: 1500);
  static const _pollTimeout = Duration(seconds: 30);

  final _apiService = ApiService();
  final _photoService = PhotoService();

  String? _fixedPhotoPath;
  int? _previewId;
  int? _nodesCount;
  int? _edgesCount;
  bool _isUploading = true;
  bool _isDetecting = false;
  String? _uploadError;

  Timer? _pollTimer;
  DateTime? _pollStart;

  @override
  void initState() {
    super.initState();
    _startPreviewUpload();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    if (_fixedPhotoPath != null) {
      _photoService.cleanupFixedPhoto(_fixedPhotoPath!);
    }
    super.dispose();
  }

  Future<void> _startPreviewUpload() async {
    String fixedPath;
    try {
      fixedPath = await _photoService.fixOrientation(widget.photoPath);
    } catch (_) {
      fixedPath = widget.photoPath;
    }

    if (!mounted) {
      if (fixedPath != widget.photoPath) {
        _photoService.cleanupFixedPhoto(fixedPath);
      }
      return;
    }

    setState(() => _fixedPhotoPath = fixedPath);

    final result = await _apiService.uploadPhotoPreview(widget.photoPath);

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    if (result['success'] != true) {
      setState(() {
        _isUploading = false;
        _uploadError = result['message'] as String?;
      });
      return;
    }

    final previewId = result['preview_id'] as int;

    if (result['nodes_count'] != null && result['edges_count'] != null) {
      setState(() {
        _previewId = previewId;
        _nodesCount = result['nodes_count'] as int;
        _edgesCount = result['edges_count'] as int;
        _isUploading = false;
      });
    } else {
      setState(() {
        _previewId = previewId;
        _isUploading = false;
        _isDetecting = true;
      });
      _startPolling();
    }
  }

  void _startPolling() {
    _pollStart = DateTime.now();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (_previewId == null || !mounted) return;

    if (DateTime.now().difference(_pollStart!) >= _pollTimeout) {
      _pollTimer?.cancel();
      setState(() => _isDetecting = false);
      return;
    }

    final result = await _apiService.getPreviewStatus(_previewId!);

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      _pollTimer?.cancel();
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    if (result['success'] == true &&
        result['nodes_count'] != null &&
        result['edges_count'] != null) {
      _pollTimer?.cancel();
      setState(() {
        _nodesCount = result['nodes_count'] as int;
        _edgesCount = result['edges_count'] as int;
        _isDetecting = false;
      });
    }
  }

  void _onUsePhoto() {
    if (_previewId == null) return;
    _pollTimer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectSelectionScreen(
          previewId: _previewId!,
          nodesCount: _nodesCount,
          edgesCount: _edgesCount,
        ),
      ),
    );
  }

  Future<void> _onNewPhoto() async {
    _pollTimer?.cancel();
    if (_previewId != null) {
      _apiService.deletePhotoPreview(_previewId!);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArchifyLogo(),
        automaticallyImplyLeading: false,
        actions: const [ScreenBadge(label: 'REVIEW')],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          const Text('Foto controleren', style: AppTextStyles.body),
          const SizedBox(height: 16),
          Expanded(child: _buildPhotoArea()),
          const SizedBox(height: 16),
          _buildDetectionStatus(),
          const SizedBox(height: 24),
          _buildButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    if (_fixedPhotoPath != null) {
      return PhotoPreviewBox(photoPath: _fixedPhotoPath!);
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.magenta),
    );
  }

  Widget _buildDetectionStatus() {
    if (_isUploading) {
      return _buildStatusRow('Foto uploaden...');
    }
    if (_uploadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          _uploadError!,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_isDetecting) {
      return _buildStatusRow('Nodes en edges detecteren...');
    }
    if (_nodesCount != null && _edgesCount != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCountChip(LucideIcons.circle, '$_nodesCount nodes'),
          const SizedBox(width: 24),
          _buildCountChip(LucideIcons.gitBranch, '$_edgesCount edges'),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusRow(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.magenta,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }

  Widget _buildCountChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.magenta, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _onNewPhoto,
              icon: const Icon(LucideIcons.camera, size: 18),
              label: const Text('Nieuwe foto'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  _isUploading || _previewId == null ? null : _onUsePhoto,
              icon: const Icon(LucideIcons.check, size: 18),
              label: const Text('Gebruik deze foto'),
            ),
          ),
        ],
      ),
    );
  }
}
