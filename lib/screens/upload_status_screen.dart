import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/main.dart';
import 'package:archify_app/models/upload_stage.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/share_service.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/screen_badge.dart';
import 'package:archify_app/widgets/status_block.dart';

class UploadStatusScreen extends StatefulWidget {
  final int photoId;
  final int projectId;

  const UploadStatusScreen({
    super.key,
    required this.photoId,
    required this.projectId,
  });

  @override
  State<UploadStatusScreen> createState() => _UploadStatusScreenState();
}

class _UploadStatusScreenState extends State<UploadStatusScreen> {
  static const Duration _pollInterval = Duration(milliseconds: 1500);
  static const Duration _pollTimeout = Duration(seconds: 90);
  static const Duration _uploadedHold = Duration(milliseconds: 1500);

  final ApiService _apiService = ApiService();
  final ShareService _shareService = ShareService();
  final GlobalKey _shareButtonKey = GlobalKey();

  UploadStage _stage = UploadStage.uploaded;
  int? _nodesCount;
  int? _edgesCount;
  int? _sketchId;
  String? _errorMessage;
  bool _isSharing = false;

  Timer? _pollTimer;
  DateTime? _pollStartedAt;

  @override
  void initState() {
    super.initState();
    _runFlow();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Polling logic ──────────────────────────────────────────────

  Future<void> _runFlow() async {
    await Future.delayed(_uploadedHold);
    if (!mounted) return;

    setState(() => _stage = UploadStage.processing);
    _pollStartedAt = DateTime.now();
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    _pollTimer = Timer(_pollInterval, _pollOnce);
  }

  Future<void> _pollOnce() async {
    if (!mounted) return;

    final result = await _apiService.getPhotoStatus(widget.photoId);
    if (!mounted) return;

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return;
    }

    if (result['success'] != true) {
      _failWith(result['message'] as String? ?? 'Status ophalen mislukt.');
      return;
    }

    final status = result['status'] as String?;
    if (status == 'completed') {
      setState(() {
        _stage = UploadStage.completed;
        _nodesCount = (result['nodes_count'] as int?) ?? 0;
        _edgesCount = (result['edges_count'] as int?) ?? 0;
        _sketchId = result['sketch_id'] as int?;
      });
      return;
    }

    if (status == 'failed') {
      _failWith(
        (result['error_message'] as String?) ??
            'De foto kon niet verwerkt worden.',
      );
      return;
    }

    final elapsed = DateTime.now().difference(_pollStartedAt!);
    if (elapsed >= _pollTimeout) {
      _failWith(
        'Verwerking duurt langer dan verwacht. Probeer het later opnieuw.',
      );
      return;
    }

    _scheduleNextPoll();
  }

  void _failWith(String message) {
    setState(() {
      _stage = UploadStage.failed;
      _errorMessage = message;
    });
  }

  // ── Actions ────────────────────────────────────────────────────

  Future<void> _onShare() async {
    if (_sketchId == null || _isSharing) return;

    setState(() => _isSharing = true);

    await _shareService.shareSketch(
      context: context,
      projectId: widget.projectId,
      sketchId: _sketchId!,
      shareOrigin: _shareOriginRect(),
    );

    if (mounted) setState(() => _isSharing = false);
  }

  Rect _shareOriginRect() {
    final renderObject =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject != null && renderObject.hasSize) {
      final origin = renderObject.localToGlobal(Offset.zero);
      return origin & renderObject.size;
    }
    final size = MediaQuery.of(context).size;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 80),
      width: 1,
      height: 1,
    );
  }

  void _onDone() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // ── UI ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArchifyLogo(),
        automaticallyImplyLeading: false,
        actions: const [ScreenBadge(label: 'STATUS')],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Center(child: _buildStageContent())),
              if (_stage == UploadStage.completed) _buildCompletedActions(),
              if (_stage == UploadStage.failed) _buildFailedActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case UploadStage.uploaded:
        return const StatusBlock(
          icon: LucideIcons.uploadCloud,
          iconColor: AppColors.magenta,
          title: 'Foto succesvol geüpload',
          subtitle: 'Een moment, we beginnen met verwerken...',
          showSpinner: true,
        );
      case UploadStage.processing:
        return const StatusBlock(
          icon: LucideIcons.loader,
          iconColor: AppColors.magenta,
          title: 'Bezig met verwerken...',
          subtitle:
              'We detecteren je nodes en pijlen. Dit duurt meestal een paar seconden.',
          showSpinner: true,
        );
      case UploadStage.completed:
        return StatusBlock(
          icon: LucideIcons.checkCircle2,
          iconColor: AppColors.magenta,
          title: 'Foto succesvol verwerkt',
          subtitle:
              '${_nodesCount ?? 0} nodes en ${_edgesCount ?? 0} pijlen gedetecteerd',
        );
      case UploadStage.failed:
        return StatusBlock(
          icon: LucideIcons.alertTriangle,
          iconColor: AppColors.magenta,
          title: 'Verwerking mislukt',
          subtitle:
              _errorMessage ??
              'Er ging iets mis bij het verwerken van je foto.',
        );
    }
  }

  Widget _buildCompletedActions() {
    return Column(
      children: [
        SizedBox(
          key: _shareButtonKey,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSharing ? null : _onShare,
            icon: _isSharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(LucideIcons.share2, size: 18),
            label: Text(_isSharing ? 'Link aanmaken...' : 'Schets delen'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _onDone,
            icon: const Icon(LucideIcons.camera, size: 18),
            label: const Text('Klaar'),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedActions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onDone,
        icon: const Icon(LucideIcons.arrowLeft, size: 18),
        label: const Text('Terug naar camera'),
      ),
    );
  }
}

