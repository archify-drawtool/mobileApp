import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/main.dart';

class ShareService {
  final ApiService _apiService = ApiService();

  /// Enables a share link and opens the system share sheet.
  /// Returns true if share was initiated successfully, false otherwise.
  /// Sets [onError] callback for error messages.
  Future<bool> shareSketch({
    required BuildContext context,
    required int projectId,
    required int sketchId,
    required Rect shareOrigin,
  }) async {
    final result = await _apiService.enableShareLink(
      projectId: projectId,
      sketchId: sketchId,
    );

    if (result['unauthorized'] == true) {
      await AuthGate.logoutAndRedirect(context);
      return false;
    }

    if (result['success'] != true) {
      _showError(context, 'Delen mislukt: ${result['message'] ?? 'onbekende fout'}');
      return false;
    }

    final token = result['token'] as String?;
    if (token == null) {
      _showError(context, 'Geen deellink ontvangen.');
      return false;
    }

    final shareUrl = '${ApiService.webAppUrl}/gedeeld/$token';

    await SharePlus.instance.share(
      ShareParams(
        text: shareUrl,
        subject: 'Bekijk mijn schets in Archify',
        sharePositionOrigin: shareOrigin,
      ),
    );

    return true;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

