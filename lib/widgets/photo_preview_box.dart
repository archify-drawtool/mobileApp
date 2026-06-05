import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archify_app/theme/app_theme.dart';

class PhotoPreviewBox extends StatefulWidget {
  final String photoPath;

  /// Number of 90° clockwise turns to apply to the preview (0–3).
  final int quarterTurns;
  final bool animateRotation;

  const PhotoPreviewBox({
    super.key,
    required this.photoPath,
    this.quarterTurns = 0,
    this.animateRotation = true,
  });

  @override
  State<PhotoPreviewBox> createState() => _PhotoPreviewBoxState();
}

class _PhotoPreviewBoxState extends State<PhotoPreviewBox> {
  static const _rotationDuration = Duration(milliseconds: 230);

  double _incomingOffset = 0;

  @override
  void didUpdateWidget(PhotoPreviewBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldTurns = _normaliseTurns(oldWidget.quarterTurns);
    final newTurns = _normaliseTurns(widget.quarterTurns);
    if (oldTurns == newTurns) return;

    final clockwiseDelta = (newTurns - oldTurns + 4) % 4;
    final signedDelta = clockwiseDelta == 3 ? -1 : clockwiseDelta;
    _incomingOffset = -signedDelta / 4;
  }

  int _normaliseTurns(int turns) => ((turns % 4) + 4) % 4;

  @override
  Widget build(BuildContext context) {
    final turns = _normaliseTurns(widget.quarterTurns);
    final framedPhoto = _buildFramedPhoto(turns);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: widget.animateRotation
              ? AnimatedSwitcher(
                  duration: _rotationDuration,
                  switchInCurve: Curves.easeOutCubic,
                  layoutBuilder: (currentChild, _) {
                    return currentChild ?? const SizedBox.shrink();
                  },
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );

                    return RotationTransition(
                      turns: Tween<double>(
                        begin: _incomingOffset,
                        end: 0,
                      ).animate(curved),
                      child: child,
                    );
                  },
                  child: framedPhoto,
                )
              : framedPhoto,
        ),
      ),
    );
  }

  Widget _buildFramedPhoto(int turns) {
    return Container(
      key: ValueKey(turns),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.magenta, width: 2),
      ),
      child: ClipRect(
        child: RotatedBox(
          quarterTurns: turns,
          child: Image.file(File(widget.photoPath)),
        ),
      ),
    );
  }
}
