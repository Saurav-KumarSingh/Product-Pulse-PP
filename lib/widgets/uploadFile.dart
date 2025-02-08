import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UploadService {
  static String cloudName = dotenv.env['Cloud_Name'] ?? '';
  static const String uploadPreset = 'product_pulse'; // Replace with your upload preset

  /// Uploads an image to Cloudinary and returns the image URL.
  static Future<String> uploadImageToCloudinary(File imageFile) async {
    final String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = json.decode(responseString);
      return jsonResponse['secure_url']; // Return the uploaded image URL
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
