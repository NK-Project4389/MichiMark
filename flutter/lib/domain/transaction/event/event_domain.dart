import 'package:equatable/equatable.dart';
import '../../master/member/member_domain.dart';
import '../../master/trans/trans_domain.dart';
import '../../master/tag/tag_domain.dart';
import '../mark_link/mark_link_domain.dart';
import '../payment/payment_domain.dart';
import '../../topic/topic_domain.dart';
import '../../action_time/action_time_log.dart';

class EventDomain extends Equatable {
  final String id;

  /// イベント名（入力必須）
  final String eventName;

  /// 使用する交通手段
  final TransDomain? trans;

  /// 参加メンバー
  final List<MemberDomain> members;

  /// タグ
  final List<TagDomain> tags;

  /// 燃費（単位: 0.1km/L の10倍整数値。例: 15.5km/L → 155）
  final int? kmPerGas;

  /// ガソリン単価（単位: 1円/L）
  final int? pricePerGas;

  /// ガソリン支払者
  final MemberDomain? payMember;

  /// マーク/リンク一覧
  final List<MarkLinkDomain> markLinks;

  /// 支払情報一覧
  final List<PaymentDomain> payments;

  /// 設定されたTopic。null = movingCost相当にフォールバック
  final TopicDomain? topic;

  /// イベントに紐づくActionTimeLogの一覧（timestamp ASC順）
  final List<ActionTimeLog> actionTimeLogs;

  /// 論理削除フラグ
  final bool isDeleted;

  /// 登録日（初回のみ設定）
  final DateTime createdAt;

  /// 更新日（保存時更新）
  final DateTime updatedAt;

  const EventDomain({
    required this.id,
    required this.eventName,
    this.trans,
    this.members = const [],
    this.tags = const [],
    this.kmPerGas,
    this.pricePerGas,
    this.payMember,
    this.markLinks = const [],
    this.payments = const [],
    this.topic,
    this.actionTimeLogs = const [],
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  EventDomain copyWith({
    String? id,
    String? eventName,
    TransDomain? trans,
    List<MemberDomain>? members,
    List<TagDomain>? tags,
    int? kmPerGas,
    int? pricePerGas,
    MemberDomain? payMember,
    List<MarkLinkDomain>? markLinks,
    List<PaymentDomain>? payments,
    TopicDomain? topic,
    List<ActionTimeLog>? actionTimeLogs,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearTopic = false,
  }) {
    return EventDomain(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      trans: trans ?? this.trans,
      members: members ?? this.members,
      tags: tags ?? this.tags,
      kmPerGas: kmPerGas ?? this.kmPerGas,
      pricePerGas: pricePerGas ?? this.pricePerGas,
      payMember: payMember ?? this.payMember,
      markLinks: markLinks ?? this.markLinks,
      payments: payments ?? this.payments,
      topic: clearTopic ? null : (topic ?? this.topic),
      actionTimeLogs: actionTimeLogs ?? this.actionTimeLogs,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventName,
        trans,
        members,
        tags,
        kmPerGas,
        pricePerGas,
        payMember,
        markLinks,
        payments,
        topic,
        actionTimeLogs,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
