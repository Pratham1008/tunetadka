import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/track_services.dart';

class UploadTrackPage extends StatefulWidget {
  final String userEmail;

  const UploadTrackPage({super.key, required this.userEmail});

  @override
  State<UploadTrackPage> createState() => _UploadTrackPageState();
}

class _UploadTrackPageState extends State<UploadTrackPage> {
  final TextEditingController _titleController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  int _progress = 0;
  String? _coverImageUrl;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and select a file")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _progress = 0;
      _coverImageUrl = null;
    });

    try {
      final response = await TrackService.uploadTrack(
        _titleController.text.trim(),
        widget.userEmail,
        _selectedFile!,
        onSendProgress: (sent, total) {
          setState(() => _progress = ((sent / total) * 100).round());
        },
      );

      // Assume response is track ID
      final trackId = response.trim();
      final coverUri = TrackService.getCoverImageUrl(trackId);

      setState(() {
        _coverImageUrl = coverUri.toString();
        _titleController.clear();
        _selectedFile = null;
        _progress = 100;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Track uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload track")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _selectedFile?.path.split('/').last;
    final isFileSelected = fileName != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0B20),
      appBar: AppBar(
        title: const Text("Upload Track"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Animate(
          effects: [FadeEffect(duration: 600.ms), SlideEffect(begin: const Offset(0, 0.2))],
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Track Title",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.audiotrack),
                    label: Text(
                      isFileSelected
                          ? (fileName.length > 28 ? "${fileName.substring(0, 25)}..." : fileName)
                          : "Pick Audio File",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  if (isFileSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Selected: $fileName",
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 36),
                  _isUploading
                      ? Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _progress.toDouble()),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) => Column(
                          children: [
                            LinearProgressIndicator(
                              value: value / 100,
                              backgroundColor: Colors.white24,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 12),
                            Text("Uploading... ${value.toStringAsFixed(0)}%",
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  )
                      : ElevatedButton.icon(
                    onPressed: _upload,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text("Upload Track"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  if (_coverImageUrl != null) ...[
                    const SizedBox(height: 32),
                    const Text("Cover Preview",
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: _coverImageUrl!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.image_not_supported, color: Colors.white54),
                      ),
                    ).animate().fade().scale(duration: 500.ms),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
