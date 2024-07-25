import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial_video_trimmer/view/trimmer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Trimmer'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('LOAD VIDEO'),
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowCompression: false,
            );

            if (result != null) {
              final file = File(result.files.single.path!);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrimmerScreen(file),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
