import 'package:equatable/equatable.dart';

class ActionSettingDetailDraft extends Equatable {
  final String actionName;
  final bool isVisible;

  const ActionSettingDetailDraft({
    this.actionName = '',
    this.isVisible = true,
  });

  ActionSettingDetailDraft copyWith({
    String? actionName,
    bool? isVisible,
  }) {
    return ActionSettingDetailDraft(
      actionName: actionName ?? this.actionName,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [actionName, isVisible];
}
