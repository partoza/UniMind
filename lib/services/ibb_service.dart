import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;

class IBBService {
  static const String _apiKey = '52c24b6907e1dbedb40f6d4cc83cf323'; 
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// A helper function to process the image:
  /// 1. Decodes the image file.
  /// 2. Resizes it (e.g., max width of 800 pixels).
  /// 3. Re-encodes it as a JPEG with a lower quality (e.g., 85).
  static Future<List<int>?> _processImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      print('Could not decode image file.');
      return null;
    }

    // --- 1. Resizing (Optional but Recommended) ---
    // Example: Resize to a max width of 800 pixels to lower resolution
    const int maxWidth = 500;
    img.Image resizedImage;
    if (image.width > maxWidth) {
      resizedImage = img.copyResize(image, width: maxWidth);
    } else {
      resizedImage = image;
    }

    // --- 2. Compression ---
    // Example: Encode as JPEG with quality 85 to reduce file size.
    // Quality ranges from 0 (worst) to 100 (best).
    const int jpegQuality = 85; 
    return img.encodeJpg(resizedImage, quality: jpegQuality);
  }


  static Future<String?> uploadImage(File imageFile) async {
    // 1. Process/Resize the image before upload
    final processedImageBytes = await _processImage(imageFile);

    if (processedImageBytes == null) {
      return null;
    }
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['key'] = _apiKey;
      
      // IBB uses 'image' as the parameter name for the file data
      // Use the compressed/resized bytes directly instead of the file path
      request.files.add(http.MultipartFile.fromBytes(
        'image', 
        processedImageBytes,
        filename: 'processed_image.jpg', // Give it a filename
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // The URL of the uploaded image
          // NOTE: data['data']['thumb']['url'] or data['data']['medium']['url'] 
          // can be used for even faster fetching post-upload, but the main 'url' 
          // now points to the resized version.
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