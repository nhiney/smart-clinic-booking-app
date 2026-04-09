import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FileStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadDoctorResume({
    required String doctorId,
    required File file,
  }) async {
    try {
      final extension = p.extension(file.path);
      final fileName = 'resume_$doctorId$extension';
      final ref = _storage.ref().child('doctors/$doctorId/$fileName');
      
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'application/pdf'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Lỗi khi tải file lên: $e');
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore or log error
    }
  }
}
