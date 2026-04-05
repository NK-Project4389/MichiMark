import '../../../domain/action_time/action_state.dart';
import '../../../domain/master/action/action_domain.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_domain.dart';
import '../../../domain/transaction/event/event_domain.dart';
import '../../../domain/transaction/mark_link/mark_link_domain.dart';
import '../../../domain/transaction/mark_link/mark_or_link.dart';
import '../../../domain/transaction/payment/payment_domain.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

DateTime _d(int year, int month, int day, [int hour = 0, int minute = 0]) =>
    DateTime(year, month, day, hour, minute);

// --- Topics ---
final seedTopics = [
  TopicDomain(
    id: 'topic-001',
    topicName: '移動コスト可視化',
    topicType: TopicType.movingCost,
    isVisible: true,
    isDeleted: false,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
    color: 'emeraldGreen',
  ),
  TopicDomain(
    id: 'topic-002',
    topicName: '旅費可視化',
    topicType: TopicType.travelExpense,
    isVisible: true,
    isDeleted: false,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
    color: 'amberOrange',
  ),
];

// --- Actions ---
// デフォルトマスタ（REQ-005対応: 出発・到着の2種）
// TopicConfig.markActionsで参照される固定IDを使用する
final seedActions = [
  ActionDomain(
    id: 'action-seed-depart',
    actionName: '出発',
    toState: ActionState.moving,
    isToggle: false,
    needsTransition: true,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'action-seed-arrive',
    actionName: '到着',
    toState: ActionState.working,
    isToggle: false,
    needsTransition: true,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'action-001',
    actionName: '観光',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'action-002',
    actionName: '食事',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'action-003',
    actionName: '休憩',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'action-004',
    actionName: '買い物',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'action-005',
    actionName: '写真撮影',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
];

// --- Members ---
final seedMembers = [
  MemberDomain(
    id: 'member-001',
    memberName: '太郎',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  MemberDomain(
    id: 'member-002',
    memberName: '花子',
    mailAddress: 'hanako@example.com',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  MemberDomain(
    id: 'member-003',
    memberName: '健太',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
];

// --- Tags ---
final seedTags = [
  TagDomain(
    id: 'tag-001',
    tagName: '家族旅行',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TagDomain(
    id: 'tag-002',
    tagName: '日帰り',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TagDomain(
    id: 'tag-003',
    tagName: '温泉',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
];

// --- Trans (交通手段) ---
final seedTrans = [
  TransDomain(
    id: 'trans-001',
    transName: 'マイカー',
    kmPerGas: 155, // 15.5 km/L
    meterValue: 45230,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TransDomain(
    id: 'trans-002',
    transName: 'レンタカー',
    kmPerGas: 200, // 20.0 km/L
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
];

// ---------------------------------------------------------------------------
// Transaction Data
// ---------------------------------------------------------------------------

/// イベント1: 箱根日帰りドライブ（マーク3つ、リンク2つ、支払い2つ）
final _event1 = EventDomain(
  id: 'event-001',
  eventName: '箱根日帰りドライブ',
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0], seedMembers[1]], // 太郎, 花子
  tags: [seedTags[1], seedTags[2]], // 日帰り, 温泉
  kmPerGas: 155,
  pricePerGas: 170,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-001',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 3, 15, 8, 0),
      markLinkName: '自宅出発',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 45230,
      actions: [seedActions[4]], // 写真撮影
      createdAt: _d(2026, 3, 15, 8, 0),
      updatedAt: _d(2026, 3, 15, 8, 0),
    ),
    MarkLinkDomain(
      id: 'ml-002',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 3, 15, 8, 30),
      markLinkName: '東名高速',
      members: [seedMembers[0], seedMembers[1]],
      distanceValue: 85,
      createdAt: _d(2026, 3, 15, 8, 30),
      updatedAt: _d(2026, 3, 15, 8, 30),
    ),
    MarkLinkDomain(
      id: 'ml-003',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 3, 15, 10, 0),
      markLinkName: '箱根湯本駅前',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 45315,
      actions: [seedActions[0], seedActions[4]], // 観光, 写真撮影
      memo: '駅前の足湯に入った',
      createdAt: _d(2026, 3, 15, 10, 0),
      updatedAt: _d(2026, 3, 15, 10, 0),
    ),
    MarkLinkDomain(
      id: 'ml-004',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 3, 15, 12, 0),
      markLinkName: '芦ノ湖スカイライン',
      members: [seedMembers[0], seedMembers[1]],
      distanceValue: 25,
      createdAt: _d(2026, 3, 15, 12, 0),
      updatedAt: _d(2026, 3, 15, 12, 0),
    ),
    MarkLinkDomain(
      id: 'ml-005',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 3, 15, 13, 0),
      markLinkName: '大涌谷',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 45340,
      actions: [seedActions[0], seedActions[1], seedActions[3]], // 観光, 食事, 買い物
      memo: '黒たまごを食べた',
      isFuel: true,
      pricePerGas: 170,
      gasQuantity: 305, // 30.5L
      gasPrice: 5185,
      createdAt: _d(2026, 3, 15, 13, 0),
      updatedAt: _d(2026, 3, 15, 13, 0),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-001',
      paymentSeq: 1,
      paymentAmount: 3200,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: [seedMembers[0], seedMembers[1]],
      paymentMemo: '高速道路代',
      createdAt: _d(2026, 3, 15, 8, 30),
      updatedAt: _d(2026, 3, 15, 8, 30),
    ),
    PaymentDomain(
      id: 'pay-002',
      paymentSeq: 2,
      paymentAmount: 2400,
      paymentMember: seedMembers[1], // 花子
      splitMembers: [seedMembers[0], seedMembers[1]],
      paymentMemo: '昼食代',
      createdAt: _d(2026, 3, 15, 13, 30),
      updatedAt: _d(2026, 3, 15, 13, 30),
    ),
  ],
  createdAt: _d(2026, 3, 15, 8, 0),
  updatedAt: _d(2026, 3, 15, 18, 0),
);

/// イベント2: 富士五湖キャンプ（マーク2つ、リンク1つ、支払い3つ）
final _event2 = EventDomain(
  id: 'event-002',
  eventName: '富士五湖キャンプ',
  trans: seedTrans[0], // マイカー
  members: seedMembers, // 太郎, 花子, 健太
  tags: [seedTags[0]], // 家族旅行
  kmPerGas: 155,
  pricePerGas: 168,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-006',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 3, 22, 7, 0),
      markLinkName: '自宅出発',
      members: seedMembers,
      meterValue: 45500,
      createdAt: _d(2026, 3, 22, 7, 0),
      updatedAt: _d(2026, 3, 22, 7, 0),
    ),
    MarkLinkDomain(
      id: 'ml-007',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 3, 22, 7, 30),
      markLinkName: '中央道',
      members: seedMembers,
      distanceValue: 110,
      createdAt: _d(2026, 3, 22, 7, 30),
      updatedAt: _d(2026, 3, 22, 7, 30),
    ),
    MarkLinkDomain(
      id: 'ml-008',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 3, 22, 9, 30),
      markLinkName: '河口湖キャンプ場',
      members: seedMembers,
      meterValue: 45610,
      actions: [seedActions[0], seedActions[2]], // 観光, 休憩
      memo: '富士山がきれいに見えた',
      createdAt: _d(2026, 3, 22, 9, 30),
      updatedAt: _d(2026, 3, 22, 9, 30),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-003',
      paymentSeq: 1,
      paymentAmount: 4500,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: seedMembers,
      paymentMemo: '高速道路代',
      createdAt: _d(2026, 3, 22, 7, 30),
      updatedAt: _d(2026, 3, 22, 7, 30),
    ),
    PaymentDomain(
      id: 'pay-004',
      paymentSeq: 2,
      paymentAmount: 8000,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: seedMembers,
      paymentMemo: 'キャンプ場利用料',
      createdAt: _d(2026, 3, 22, 9, 30),
      updatedAt: _d(2026, 3, 22, 9, 30),
    ),
    PaymentDomain(
      id: 'pay-005',
      paymentSeq: 3,
      paymentAmount: 3600,
      paymentMember: seedMembers[2], // 健太
      splitMembers: seedMembers,
      paymentMemo: 'BBQ食材',
      createdAt: _d(2026, 3, 22, 11, 0),
      updatedAt: _d(2026, 3, 22, 11, 0),
    ),
  ],
  createdAt: _d(2026, 3, 22, 7, 0),
  updatedAt: _d(2026, 3, 23, 15, 0),
);

/// イベント3: シンプルなイベント（markLinks・payments なし）
final _event3 = EventDomain(
  id: 'event-003',
  eventName: '近所のドライブ',
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0]], // 太郎のみ
  tags: [seedTags[1]], // 日帰り
  createdAt: _d(2026, 3, 28, 14, 0),
  updatedAt: _d(2026, 3, 28, 16, 0),
);

final seedEvents = [_event1, _event2, _event3];
