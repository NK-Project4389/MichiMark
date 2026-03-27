import 'package:equatable/equatable.dart';
import '../selection_args.dart';

class SelectionItemProjection extends Equatable {
  final String id;
  final String label;
  final String? subLabel;
  final bool isSelected;

  const SelectionItemProjection({
    required this.id,
    required this.label,
    this.subLabel,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [id, label, subLabel, isSelected];
}

class SelectionProjection extends Equatable {
  final String title;
  final SelectionMode mode;
  final List<SelectionItemProjection> items;

  const SelectionProjection({
    required this.title,
    required this.mode,
    required this.items,
  });

  @override
  List<Object?> get props => [title, mode, items];
}
