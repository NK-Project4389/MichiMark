import 'package:equatable/equatable.dart';

class TagDomain extends Equatable {
  final String id;

  /// タグ名（入力必須）
  final String tagName;

  /// 表示フラグ（true: 表示 / false: 非表示）
  final bool isVisible;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  const TagDomain({
    required this.id,
    required this.tagName,
    this.isVisible = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  TagDomain copyWith({
    String? id,
    String? tagName,
    bool? isVisible,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TagDomain(
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tagName,
        isVisible,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
