import '../domain/master/tag/tag_domain.dart';

/// タグの永続化インターフェース
///
/// 削除は論理削除（isDeleted フラグ）で行うため、deleteメソッドは持たない。
/// 新規作成・更新は save で一本化する（upsert）。
abstract interface class TagRepository {
  /// 論理削除されていないタグを全件取得
  Future<List<TagDomain>> fetchAll();

  /// タグを保存（新規作成 / 上書き更新）
  Future<void> save(TagDomain tag);
}
