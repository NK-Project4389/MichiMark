abstract class AuthRepository {
  /// 現在のFirebase Auth UID。未サインインならnull。
  String? get currentUid;

  /// Anonymous Authサインイン。発行されたUIDを返す。
  Future<String> signInAnonymously();

  /// Apple Sign Inサインイン。UIDを返す。
  Future<String> signInWithApple();

  /// AnonymousアカウントにApple IDをリンクする。
  Future<void> linkWithApple();

  /// Apple Sign In連携済みかどうか。
  bool get isAppleLinked;

  /// サインアウト。AnonymousユーザーはUIDが失われるため要注意。
  Future<void> signOut();
}
