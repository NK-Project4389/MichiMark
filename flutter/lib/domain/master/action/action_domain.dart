import 'package:equatable/equatable.dart';

class ActionDomain extends Equatable {
  final String id;

  /// アクション名（入力必須）
  final String actionName;

  /// 表示フラグ（true: 表示 / false: 非表示）
  final bool isVisible;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  const ActionDomain({
    required this.id,
    required this.actionName,
    this.isVisible = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  ActionDomain copyWith({
    String? id,
    String? actionName,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActionDomain(
      id: id ?? this.id,
      actionName: actionName ?? this.actionName,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        actionName,
        isVisible,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
