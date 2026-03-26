import 'package:equatable/equatable.dart';
import '../../shared/projection/mark_link_item_projection.dart';

class MichiInfoListProjection extends Equatable {
  final List<MarkLinkItemProjection> items;

  const MichiInfoListProjection({required this.items});

  static const empty = MichiInfoListProjection(items: []);

  @override
  List<Object?> get props => [items];
}
