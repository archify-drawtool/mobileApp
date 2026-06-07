import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/photo_preview_box.dart';
import 'package:archify_app/widgets/screen_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/screens/project_selection_screen.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final String photoPath;

  const PhotoPreviewScreen({super.key, required this.photoPath});

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  /// 0–3 clockwise quarter turns the user has applied to the photo.
  int _quarterTurns = 0;

  void _rotateClockwise() {
    setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
  }

  void _rotateCounterClockwise() {
    setState(() => _quarterTurns = (_quarterTurns + 3) % 4);
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
        actions: [const ScreenBadge(label: 'PREVIEW')],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          const Text('Foto gebruiken?', style: AppTextStyles.body),
          const SizedBox(height: 16),
          Expanded(
            child: PhotoPreviewBox(
              photoPath: widget.photoPath,
              quarterTurns: _quarterTurns,
            ),
          ),
          const SizedBox(height: 16),
          Row(
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
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    label: const Text('Opnieuw'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectSelectionScreen(
                            photoPath: widget.photoPath,
                            quarterTurns: _quarterTurns,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text('Accepteren'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
