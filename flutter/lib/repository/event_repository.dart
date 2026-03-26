import '../domain/transaction/event/event_domain.dart';

/// イベントの永続化インターフェース
///
/// 実装はdriftを使用する。
/// FeatureはこのインターフェースをDI経由で取得し、直接呼び出しは禁止。
abstract interface class EventRepository {
  /// 論理削除されていないイベントを全件取得（更新日降順）
  Future<List<EventDomain>> fetchAll();

  /// 指定IDのイベントを取得
  ///
  /// 存在しない場合は [NotFoundError] をthrowする
  Future<EventDomain> fetch(String id);

  /// イベントを保存（新規作成 / 上書き更新）
  Future<void> save(EventDomain event);

  /// イベントを論理削除する
  Future<void> delete(String id);
}
