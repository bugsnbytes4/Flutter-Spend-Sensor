// lib/services/storage_service.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadReceipt(Uint8List bytes, String uid, {String ext = 'jpg'}) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    final path = 'receipts/$uid/$id.$ext';
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }
}

