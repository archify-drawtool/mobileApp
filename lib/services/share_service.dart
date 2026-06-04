import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archify_app/services/api_service.dart';

class ShareService {
  Future<void> shareSketch({
    int? projectId,
    required int sketchId,
    required Rect shareOrigin,
  }) async {
    final shareUrl = projectId == null
        ? '${ApiService.webAppUrl}/schetsen/$sketchId'
        : '${ApiService.webAppUrl}/projecten/$projectId/schetsen/$sketchId';

    await SharePlus.instance.share(
      ShareParams(
        text: shareUrl,
        subject: 'Bekijk mijn schets in Archify',
        sharePositionOrigin: shareOrigin,
      ),
    );
  }
}
