import '../domain/master/action/action_domain.dart';

/// アクションの永続化インターフェース
///
/// 削除は論理削除（isDeleted フラグ）で行うため、deleteメソッドは持たない。
/// 新規作成・更新は save で一本化する（upsert）。
abstract interface class ActionRepository {
  /// 論理削除されていないアクションを全件取得
  Future<List<ActionDomain>> fetchAll();

  /// アクションを保存（新規作成 / 上書き更新）
  Future<void> save(ActionDomain action);
}
