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
  int _quarterTurns = 0;
  int? _previewId;
  int? _nodesCount;
  int? _edgesCount;
  bool _orientationConfirmed = false;
  bool _isUploading = false;
  bool _isDetecting = false;
  String? _uploadError;

  Timer? _pollTimer;
  DateTime? _pollStart;

  bool get _canUsePhoto =>
      _previewId != null &&
      !_isUploading &&
      !_isDetecting &&
      _uploadError == null &&
      _nodesCount != null &&
      _edgesCount != null;

  @override
  void dispose() {
    _pollTimer?.cancel();
    if (_fixedPhotoPath != null) {
      _photoService.cleanupFixedPhoto(_fixedPhotoPath!);
    }
    super.dispose();
  }

  void _rotateClockwise() {
    if (_orientationConfirmed) return;
    setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
  }

  void _rotateCounterClockwise() {
    if (_orientationConfirmed) return;
    setState(() => _quarterTurns = (_quarterTurns + 3) % 4);
  }

  Future<void> _onContinue() async {
    if (_orientationConfirmed || _isUploading) return;

    setState(() {
      _orientationConfirmed = true;
      _isUploading = true;
      _isDetecting = false;
      _uploadError = null;
      _previewId = null;
      _nodesCount = null;
      _edgesCount = null;
    });

    final String fixedPath;
    try {
      fixedPath = await _photoService.fixOrientation(
        widget.photoPath,
        quarterTurns: _quarterTurns,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadError = 'Foto voorbereiden mislukt. Maak een nieuwe foto.';
      });
      return;
    }

    if (!mounted) {
      if (fixedPath != widget.photoPath) {
        _photoService.cleanupFixedPhoto(fixedPath);
      }
      return;
    }

    setState(() {
      _fixedPhotoPath = fixedPath;
      _quarterTurns = 0;
    });

    final result = await _apiService.uploadPhotoPreview(fixedPath);

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    if (result['success'] != true || result['preview_id'] is! int) {
      setState(() {
        _isUploading = false;
        _uploadError = result['message'] as String?;
      });
      return;
    }

    final previewId = result['preview_id'] as int;

    if (result['nodes_count'] is int && result['edges_count'] is int) {
      setState(() {
        _previewId = previewId;
        _nodesCount = result['nodes_count'] as int;
        _edgesCount = result['edges_count'] as int;
        _isUploading = false;
      });
      return;
    }

    setState(() {
      _previewId = previewId;
      _isUploading = false;
      _isDetecting = true;
    });
    _startPolling();
  }

  void _startPolling() {
    _pollStart = DateTime.now();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (_previewId == null || !mounted || _pollStart == null) return;

    if (DateTime.now().difference(_pollStart!) >= _pollTimeout) {
      _pollTimer?.cancel();
      setState(() {
        _isDetecting = false;
        _uploadError = 'Detectie duurde te lang. Maak een nieuwe foto.';
      });
      return;
    }

    final result = await _apiService.getPreviewStatus(_previewId!);

    if (!mounted) return;

    if (result['unauthorized'] == true) {
      _pollTimer?.cancel();
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    if (result['success'] != true) return;

    if (result['status'] == 'failed') {
      _pollTimer?.cancel();
      setState(() {
        _isDetecting = false;
        _uploadError = 'Detectie mislukt. Maak een nieuwe foto.';
      });
      return;
    }

    if (result['nodes_count'] is int && result['edges_count'] is int) {
      _pollTimer?.cancel();
      setState(() {
        _nodesCount = result['nodes_count'] as int;
        _edgesCount = result['edges_count'] as int;
        _isDetecting = false;
      });
    }
  }

  void _onUsePhoto() {
    if (!_canUsePhoto) return;
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
    final previewId = _previewId;
    if (previewId != null) {
      await _apiService.deletePhotoPreview(previewId);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _rotateButton({
    required String semanticLabel,
    required String tooltip,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Tooltip(
          message: tooltip,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArchifyLogo(),
        automaticallyImplyLeading: false,
        actions: [
          ScreenBadge(label: _orientationConfirmed ? 'REVIEW' : 'DRAAIEN'),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            _orientationConfirmed ? 'Foto controleren' : 'Zet de foto rechtop',
            style: AppTextStyles.body,
          ),
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
    return PhotoPreviewBox(
      photoPath: _fixedPhotoPath ?? widget.photoPath,
      quarterTurns: _quarterTurns,
      animateRotation: !_orientationConfirmed,
    );
  }

  Widget _buildDetectionStatus() {
    if (!_orientationConfirmed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _rotateButton(
            semanticLabel: 'Foto 90 graden linksom draaien',
            tooltip: 'Linksom draaien',
            icon: LucideIcons.rotateCcw,
            label: 'Linksom',
            onPressed: _rotateCounterClockwise,
          ),
          const SizedBox(width: 16),
          _rotateButton(
            semanticLabel: 'Foto 90 graden rechtsom draaien',
            tooltip: 'Rechtsom draaien',
            icon: LucideIcons.rotateCw,
            label: 'Rechtsom',
            onPressed: _rotateClockwise,
          ),
        ],
      );
    }

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
      child: _orientationConfirmed
          ? _buildReviewButtons()
          : _buildOrientationButtons(),
    );
  }

  Widget _buildOrientationButtons() {
    return Row(
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
            onPressed: _onContinue,
            icon: const Icon(LucideIcons.arrowRight, size: 18),
            label: const Text('Verder'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewButtons() {
    return Row(
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
            onPressed: _canUsePhoto ? _onUsePhoto : null,
            icon: const Icon(LucideIcons.check, size: 18),
            label: const Text('Gebruik deze foto'),
          ),
        ),
      ],
    );
  }
}
