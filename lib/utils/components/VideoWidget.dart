import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class VideoUploadPage extends StatefulWidget {
  @override
  _VideoUploadPageState createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> {
  File? _selectedVideo;
  bool _isUploading = false;
  String? _uploadStatus;

  // API Key di api.video
  final String apiKey = "x7tsgVXJHnUdxFFMSfN0MYkJU6NFtOLhUmDEJFbrXsM";

  // Seleziona un video dalla galleria
  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video, // Limita ai soli video
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
        _uploadStatus = null;
      });
    }
  }

  // Carica il video su api.video
  Future<void> uploadVideo() async {
    if (_selectedVideo == null) {
      setState(() {
        _uploadStatus = "No video selected";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = null;
    });

    // Endpoint corretto
    final String uploadUrl = "https://sandbox.api.video/videos";

    try {
      // 1. Crea un nuovo video su api.video
      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "title": "Video on Gallery",
          "description": "Video uploaded from gallery",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String sourceUrl = "https://sandbox.api.video" + data['source']['uri'];

        // 2. Carica il file video al link fornito
        final uploadRequest = http.MultipartRequest("POST", Uri.parse(sourceUrl));
        uploadRequest.headers['Authorization'] = 'Bearer $apiKey';
        uploadRequest.files.add(
          await http.MultipartFile.fromPath('file', _selectedVideo!.path),
        );

        final uploadResponse = await uploadRequest.send();
        if (uploadResponse.statusCode == 201) {
          setState(() {
            _uploadStatus = "Video uploaded successfully!";
          });
        } else {
          setState(() {
            _uploadStatus = "Error loading video. Status: ${uploadResponse.statusCode}";
          });
        }
      } else {
        setState(() {
          _uploadStatus = "Error creating video: ${response.body}";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _uploadStatus = "Error: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload video on api.video"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _selectedVideo != null
                ? Text(
                    "Selected video: ${_selectedVideo!.path.split('/').last}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : Text("No video selected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : pickVideo,
              child: Text("Select Video"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : uploadVideo,
              child: Text("Upload Video"),
            ),
            SizedBox(height: 20),
            if (_isUploading)
              CircularProgressIndicator()
            else if (_uploadStatus != null)
              Text(
                _uploadStatus!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _uploadStatus == "Video uploaded successfully!" ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
