import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserEntity?> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!, doc.id);
  }

  Future<void> updateProfile(UserEntity user) async {
    await _firestore.collection('users').doc(user.id).update({
      'name': user.name,
      'phone': user.phone,
      'avatarUrl': user.avatarUrl,
    });
  }
}
