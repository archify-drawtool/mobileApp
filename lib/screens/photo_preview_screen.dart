import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final String photoPath;

  const PhotoPreviewScreen({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Foto gebruiken?',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Image.file(
              File(photoPath),
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Opnieuw'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto klaar om te uploaden')),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Accepteren'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
