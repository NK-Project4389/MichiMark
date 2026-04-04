import 'package:equatable/equatable.dart';

/// Topicの用途種別enum。
/// Phase 3でカスタム種別が追加される可能性を想定し、enumを参照する形で表示制御を実装する（ハードコード禁止）。
enum TopicType {
  /// 燃料・距離・燃費の記録が主目的
  movingCost,

  /// 経費・精算の記録が主目的
  travelExpense,
}

/// TopicDomain
/// イベントに設定する用途カテゴリ。
/// UIを知らない・Draftを知らない。
class TopicDomain extends Equatable {
  /// PK（UUID文字列）
  final String id;

  /// 表示名（例: 「移動コスト可視化」）
  final String topicName;

  /// 用途種別enum
  final TopicType topicType;

  /// 選択画面での表示制御
  final bool isVisible;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日時
  final DateTime createdAt;

  /// 更新日時
  final DateTime updatedAt;

  const TopicDomain({
    required this.id,
    required this.topicName,
    required this.topicType,
    this.isVisible = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  TopicDomain copyWith({
    String? id,
    String? topicName,
    TopicType? topicType,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TopicDomain(
      id: id ?? this.id,
      topicName: topicName ?? this.topicName,
      topicType: topicType ?? this.topicType,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        topicName,
        topicType,
        isVisible,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
