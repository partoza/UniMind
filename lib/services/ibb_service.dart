import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IBBService {
  // ⚠️ REPLACE THIS WITH YOUR ACTUAL IBB API KEY ⚠️
  static const String _apiKey = '52c24b6907e1dbedb40f6d4cc83cf323'; 
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Uploads an image file to the IBB API.
  /// Returns the URL of the uploaded image on success, or null on failure.
  static Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['key'] = _apiKey;
      
      // IBB uses 'image' as the parameter name for the file data
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // The URL of the uploaded image
          return data['data']['url'] as String;
        } else {
          // Handle IBB specific error message
          print('IBB API Error: ${data['error']['message']}');
          return null;
        }
      } else {
        print('HTTP Error during IBB upload: ${response.statusCode} ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception during IBB upload: $e');
      return null;
    }
  }
}