import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/action_time/action_state.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../action_repository.dart';
import '../../auth_repository.dart';

/// ActionRepository の Firestore 実装
class FirestoreActionRepository implements ActionRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirestoreActionRepository({
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, Object?>> _collection() {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      throw StateError('FirestoreActionRepository: currentUid is null');
    }
    return _firestore.collection('organizations/$uid/actions');
  }

  @override
  Future<List<ActionDomain>> fetchAll() async {
    final snapshot =
        await _collection().where('isDeleted', isEqualTo: false).get();
    return snapshot.docs.map((doc) => _fromFirestore(doc.data())).toList();
  }

  @override
  Future<void> save(ActionDomain action) async {
    await _collection().doc(action.id).set(_toFirestore(action));
  }

  static ActionDomain _fromFirestore(Map<String, Object?> data) {
    final toStateStr = data['toState'] as String?;
    ActionState? toState;
    if (toStateStr != null) {
      toState = ActionState.values.firstWhere(
        (s) => s.name == toStateStr,
        orElse: () => ActionState.waiting,
      );
    }

    return ActionDomain(
      id: data['id'] as String,
      actionName: data['actionName'] as String,
      isVisible: data['isVisible'] as bool,
      isDeleted: data['isDeleted'] as bool,
      toState: toState,
      isToggle: data['isToggle'] as bool,
      togglePairId: data['togglePairId'] as String?,
      needsTransition: data['needsTransition'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  static Map<String, Object?> _toFirestore(ActionDomain action) {
    return {
      'id': action.id,
      'actionName': action.actionName,
      'isVisible': action.isVisible,
      'isDeleted': action.isDeleted,
      'toState': action.toState?.name,
      'isToggle': action.isToggle,
      'togglePairId': action.togglePairId,
      'needsTransition': action.needsTransition,
      'createdAt': Timestamp.fromDate(action.createdAt),
      'updatedAt': Timestamp.fromDate(action.updatedAt),
    };
  }
}
