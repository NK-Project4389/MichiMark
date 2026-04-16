/// drift → Firestore データ移行の永続化インターフェース
abstract interface class MigrationRepository {
  /// Firestoreへの移行が必要かどうかを返す
  Future<bool> isMigrationNeeded();

  /// driftからFirestoreへ全データを移行する
  Future<void> migrate();

  /// 現在のschemaVersion（0=未移行）
  Future<int> getMigrationVersion();
}
