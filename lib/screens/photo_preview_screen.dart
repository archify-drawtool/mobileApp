import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final String photoPath;

  const PhotoPreviewScreen({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Foto gebruiken?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Opnieuw'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
