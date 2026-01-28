import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class ScannerService {
  static Future<Map<String, dynamic>> scanReceipt(XFile imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      return await ApiService.scanReceipt(base64Image);
    } catch (e) {
      return {};
    }
  }
}
