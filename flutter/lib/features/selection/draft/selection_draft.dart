import 'package:equatable/equatable.dart';
import '../selection_args.dart';

class SelectionDraft extends Equatable {
  final Set<String> selectedIds;

  const SelectionDraft({this.selectedIds = const {}});

  /// idをトグルする。singleモードは常に1件のみ選択。
  SelectionDraft toggle(String id, SelectionMode mode) {
    if (mode == SelectionMode.single) {
      return SelectionDraft(selectedIds: {id});
    }
    final next = Set<String>.from(selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    return SelectionDraft(selectedIds: next);
  }

  @override
  List<Object?> get props => [selectedIds];
}
