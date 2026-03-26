import 'package:equatable/equatable.dart';

class TagItemProjection extends Equatable {
  final String id;
  final String tagName;
  final bool isVisible;

  const TagItemProjection({
    required this.id,
    required this.tagName,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [id, tagName, isVisible];
}
