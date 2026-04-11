import '../domain/aggregation/aggregation_filter.dart';
import '../domain/action_time/action_time_log.dart';
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

  // ---------------------------------------------------------------------------
  // ActionTimeLog CRUD
  // ---------------------------------------------------------------------------

  /// ActionTimeLog を保存（upsert）
  Future<void> saveActionTimeLog(ActionTimeLog log);

  /// ActionTimeLog を論理削除する
  Future<void> deleteActionTimeLog(String id);

  /// 指定イベントの ActionTimeLog を timestamp ASC で取得
  Future<List<ActionTimeLog>> fetchActionTimeLogs(String eventId);

  // ---------------------------------------------------------------------------
  // Aggregation用クエリ
  // ---------------------------------------------------------------------------

  /// 指定期間内（createdAtがstart〜end）のEventを取得する
  Future<List<EventDomain>> fetchByDateRange(DateTime start, DateTime end);

  /// AggregationFilterの全条件でフィルタしたEventを取得する
  Future<List<EventDomain>> fetchByFilter(AggregationFilter filter);

  /// MarkLink（Mark または Link）を論理削除する
  Future<void> deleteMarkLink(String markLinkId);
}
