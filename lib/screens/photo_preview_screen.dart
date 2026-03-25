import 'dart:io';
import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/photo_preview_box.dart';
import 'package:archify_app/widgets/screen_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/theme/app_theme.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final String photoPath;

  const PhotoPreviewScreen({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ArchifyLogo(),
        automaticallyImplyLeading: false,
        actions: [
          const ScreenBadge(label: 'PREVIEW'),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          const Text(
            'Foto gebruiken?',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PhotoPreviewBox(photoPath: photoPath),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(LucideIcons.refreshCw, size: 18),
                    label: const Text('Opnieuw'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto klaar om te uploaden')),
                      );
                    },
                    icon: Icon(LucideIcons.check, size: 18),
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
