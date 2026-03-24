import 'package:archify_app/widgets/archify_logo.dart';
import 'package:archify_app/widgets/photo_preview_box.dart';
import 'package:archify_app/widgets/screen_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/photo_service.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final String photoPath;

  const PhotoPreviewScreen({super.key, required this.photoPath});

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final ApiService _apiService = ApiService();
  final PhotoService _photoService = PhotoService();
  bool _isUploading = false;

  Future<void> _onAccept() async {
    setState(() => _isUploading = true);

    final fixedPath = await _photoService.fixOrientation(widget.photoPath);
    final result = await _apiService.uploadPhoto(fixedPath);

    if (!mounted) return;

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success']
              ? 'Foto is succesvol geüpload'
              : 'Upload mislukt: ${result['message']}',
        ),
      ),
    );

    if (result['success']) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

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
            child: PhotoPreviewBox(photoPath: widget.photoPath),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    label: const Text('Opnieuw'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _onAccept,
                    icon: _isUploading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                        : const Icon(LucideIcons.check, size: 18),
                    label: Text(_isUploading ? 'Uploaden...' : 'Accepteren'),
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
