import 'package:equatable/equatable.dart';

class TagSettingDetailDraft extends Equatable {
  final String tagName;
  final bool isVisible;

  const TagSettingDetailDraft({
    this.tagName = '',
    this.isVisible = true,
  });

  TagSettingDetailDraft copyWith({
    String? tagName,
    bool? isVisible,
  }) {
    return TagSettingDetailDraft(
      tagName: tagName ?? this.tagName,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [tagName, isVisible];
}
