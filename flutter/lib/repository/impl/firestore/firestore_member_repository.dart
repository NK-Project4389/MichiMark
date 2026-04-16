import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/master/member/member_domain.dart';
import '../../auth_repository.dart';
import '../../member_repository.dart';

/// MemberRepository の Firestore 実装
class FirestoreMemberRepository implements MemberRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreMemberRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, Object?>> _collection() {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreMemberRepository: currentUid is null');
    }
    return _firestore.collection('organizations/$uid/members');
  }

  @override
  Future<List<MemberDomain>> fetchAll() async {
    final snapshot =
        await _collection().where('isDeleted', isEqualTo: false).get();
    return snapshot.docs.map((doc) => _fromFirestore(doc.data())).toList();
  }

  @override
  Future<void> save(MemberDomain member) async {
    await _collection().doc(member.id).set(_toFirestore(member));
  }

  static MemberDomain _fromFirestore(Map<String, Object?> data) {
    return MemberDomain(
      id: data['id'] as String,
      memberName: data['memberName'] as String,
      mailAddress: data['mailAddress'] as String?,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Map<String, Object?> _toFirestore(MemberDomain member) {
    return {
      'id': member.id,
      'memberName': member.memberName,
      'mailAddress': member.mailAddress,
      'isVisible': member.isVisible,
      'isDeleted': member.isDeleted,
      'createdAt': Timestamp.fromDate(member.createdAt),
      'updatedAt': Timestamp.fromDate(member.updatedAt),
    };
  }
}
