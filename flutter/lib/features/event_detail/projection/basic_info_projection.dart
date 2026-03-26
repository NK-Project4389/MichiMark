import 'package:equatable/equatable.dart';
import '../../shared/projection/member_item_projection.dart';
import '../../shared/projection/trans_item_projection.dart';
import '../../shared/projection/tag_item_projection.dart';

class BasicInfoProjection extends Equatable {
  final String eventId;
  final String eventName;
  final TransItemProjection? trans;
  final List<TagItemProjection> tags;
  final List<MemberItemProjection> members;
  final int? kmPerGas;

  /// 燃費の表示文字列（例: "15.5 km/L"、未設定時は "未設定"）
  final String displayKmPerGas;

  final int? pricePerGas;

  /// ガソリン単価の表示文字列（例: "170 円/L"、未設定時は "未設定"）
  final String displayPricePerGas;

  final MemberItemProjection? payMember;

  const BasicInfoProjection({
    required this.eventId,
    required this.eventName,
    this.trans,
    required this.tags,
    required this.members,
    this.kmPerGas,
    required this.displayKmPerGas,
    this.pricePerGas,
    required this.displayPricePerGas,
    this.payMember,
  });

  static BasicInfoProjection empty(String eventId) => BasicInfoProjection(
        eventId: eventId,
        eventName: '',
        tags: const [],
        members: const [],
        displayKmPerGas: '未設定',
        displayPricePerGas: '未設定',
      );

  @override
  List<Object?> get props => [
        eventId,
        eventName,
        trans,
        tags,
        members,
        kmPerGas,
        displayKmPerGas,
        pricePerGas,
        displayPricePerGas,
        payMember,
      ];
}
