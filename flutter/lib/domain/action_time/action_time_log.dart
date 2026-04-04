import 'package:equatable/equatable.dart';

/// ActionTimeLog Domain
/// ActionTimeLogはMarkLinkとは独立してEventIDに直接紐づく新規エンティティ。
/// UIを知らない。
class ActionTimeLog extends Equatable {
  /// PK（UUID文字列）
  final String id;

  /// FK → EventDomain.id
  final String eventId;

  /// FK → ActionDomain.id
  final String actionId;

  /// Actionが発生した日時
  final DateTime timestamp;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日時
  final DateTime createdAt;

  /// 更新日時
  final DateTime updatedAt;

  const ActionTimeLog({
    required this.id,
    required this.eventId,
    required this.actionId,
    required this.timestamp,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ActionTimeLog copyWith({
    String? id,
    String? eventId,
    String? actionId,
    DateTime? timestamp,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActionTimeLog(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      actionId: actionId ?? this.actionId,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        actionId,
        timestamp,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
