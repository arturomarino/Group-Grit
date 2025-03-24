import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';


class UploadService {
  final String apiKey = "x7tsgVXJHnUdxFFMSfN0MYkJU6NFtOLhUmDEJFbrXsM";
  late final Map<String, String> headers;

  UploadService() {
    headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
  }



  Future<void> uploadVideo(File videoFile) async {
  final String uploadUrl = "https://sandbox.api.video/v1/videos";

  // Crea un nuovo video
  final response = await http.post(
    Uri.parse(uploadUrl),
    headers: headers,
    body: jsonEncode({
      "title": "Il tuo titolo video",
      "description": "Descrizione del video"
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    final String videoId = data['videoId'];
    final String sourceUrl = data['source']['uri'];

    // Carica il file video
    final request = http.MultipartRequest("POST", Uri.parse(sourceUrl));
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.files.add(
      await http.MultipartFile.fromPath('file', videoFile.path),
    );

    final uploadResponse = await request.send();
    if (uploadResponse.statusCode == 200) {
      print("Video caricato con successo!");
    } else {
      print("Errore durante il caricamento del video.");
    }
  } else {
    print("Errore nella creazione del video: ${response.body}");
  }
}


}