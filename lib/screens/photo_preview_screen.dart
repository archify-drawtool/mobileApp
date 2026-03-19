import 'dart:io';
import 'package:archify_app/widgets/archify_logo.dart';
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.magenta, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PREVIEW',
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
            'Foto gebruiken?',
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
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
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
