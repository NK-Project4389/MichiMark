import '../../auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  static const String _fakeUid = 'fake-uid-test-user';

  String? _currentUid;
  bool _isAppleLinked = false;

  @override
  String? get currentUid => _currentUid;

  @override
  Future<String> signInAnonymously() async {
    _currentUid = _fakeUid;
    return _fakeUid;
  }

  @override
  Future<String> signInWithApple() async {
    _currentUid = _fakeUid;
    _isAppleLinked = true;
    return _fakeUid;
  }

  @override
  Future<void> linkWithApple() async {
    _isAppleLinked = true;
  }

  @override
  bool get isAppleLinked => _isAppleLinked;

  @override
  Future<void> signOut() async {
    _currentUid = null;
    _isAppleLinked = false;
  }
}
