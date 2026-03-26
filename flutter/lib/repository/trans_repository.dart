import '../domain/master/trans/trans_domain.dart';

/// 交通手段の永続化インターフェース
///
/// 削除は論理削除（isDeleted フラグ）で行うため、deleteメソッドは持たない。
/// 新規作成・更新は save で一本化する（upsert）。
abstract interface class TransRepository {
  /// 論理削除されていない交通手段を全件取得
  Future<List<TransDomain>> fetchAll();

  /// 交通手段を保存（新規作成 / 上書き更新）
  Future<void> save(TransDomain trans);
}
