import '../../../domain/action_time/action_state.dart';
import '../../../domain/action_time/action_time_log.dart';
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
// Helper（テスト用・固定日付）
// ---------------------------------------------------------------------------

DateTime _d(int year, int month, int day, [int hour = 0, int minute = 0]) =>
    DateTime(year, month, day, hour, minute);

// ---------------------------------------------------------------------------
// Helper（本番用・相対日付）
// ---------------------------------------------------------------------------

final _base = DateTime.now();

/// _base から dayOffset 日ずらした DateTime を返す
DateTime _rel(int dayOffset, [int hour = 0, int minute = 0]) =>
    DateTime(_base.year, _base.month, _base.day + dayOffset, hour, minute);

/// _base の年・月の dayOfMonth 日を返す（シナリオB用）
DateTime _monthStart(int dayOfMonth, [int hour = 0, int minute = 0]) =>
    DateTime(_base.year, _base.month, dayOfMonth, hour, minute);

// --- Topics ---
final seedTopics = [
  TopicDomain(
    id: 'topic-001',
    topicName: '移動コスト（給油から計算）',
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
  TopicDomain(
    id: 'topic-003',
    topicName: '移動コスト（燃費で推定）',
    topicType: TopicType.movingCostEstimated,
    isVisible: true,
    isDeleted: false,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
    color: 'emeraldGreen',
  ),
  TopicDomain(
    id: 'topic-004',
    topicName: 'ツーリング',
    topicType: TopicType.movingCost,
    isVisible: true,
    isDeleted: false,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
    color: 'tealGreen',
  ),
  TopicDomain(
    id: 'topic-005',
    topicName: '仕事移動',
    topicType: TopicType.movingCostEstimated,
    isVisible: true,
    isDeleted: false,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
    color: 'indigoBlue',
  ),
  TopicDomain(
    id: 'topic_visit_work',
    topicName: '訪問作業',
    topicType: TopicType.visitWork,
    isVisible: true,
    isDeleted: false,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
    color: 'skyBlue',
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
  // visitWork 専用アクション（F-3）
  ActionDomain(
    id: 'visit_work_arrive',
    actionName: '到着',
    toState: ActionState.waiting,
    isToggle: false,
    needsTransition: true,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'visit_work_depart',
    actionName: '出発',
    toState: ActionState.moving,
    isToggle: false,
    needsTransition: true,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'visit_work_start',
    actionName: '作業開始',
    toState: ActionState.working,
    isToggle: false,
    needsTransition: true,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'visit_work_end',
    actionName: '作業終了',
    toState: ActionState.waiting,
    isToggle: false,
    needsTransition: true,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  ActionDomain(
    id: 'visit_work_break',
    actionName: '休憩',
    isToggle: true,
    needsTransition: true,
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
    memberName: '田中',
    mailAddress: 'hanako@example.com',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  MemberDomain(
    id: 'member-003',
    memberName: '鈴木',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
];

final _member4 = MemberDomain(
  id: 'member-004',
  memberName: '鈴木さん',
  createdAt: _d(2026, 1, 1),
  updatedAt: _d(2026, 1, 1),
);

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
  TagDomain(
    id: 'tag-004',
    tagName: 'ツーリング',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TagDomain(
    id: 'tag-005',
    tagName: 'キャンプ',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TagDomain(
    id: 'tag-006',
    tagName: 'グルメ',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TagDomain(
    id: 'tag-007',
    tagName: '出張',
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
  TagDomain(
    id: 'tag-008',
    tagName: '絶景スポット',
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
    meterValue: 0,
    createdAt: _d(2026, 1, 1),
    updatedAt: _d(2026, 1, 1),
  ),
];

// ---------------------------------------------------------------------------
// テスト用シードデータ（現行 event-001〜008 をそのまま維持）
// ※ Integration Test が依存しているため基本は変えない
// ※ _event1 の markLinks・payments の日付のみ相対日付（_rel）に変更済み（2026-04-17）
// ---------------------------------------------------------------------------

/// イベント1: 箱根日帰りドライブ（マーク3つ、リンク2つ、支払い2つ）
final _event1 = EventDomain(
  id: 'event-001',
  eventName: '箱根日帰りドライブ',
  topic: seedTopics[0], // 移動コスト可視化
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0], seedMembers[1]], // 太郎, 田中
  tags: [seedTags[1], seedTags[2]], // 日帰り, 温泉
  kmPerGas: 155,
  pricePerGas: 170,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-001',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-5, 8, 0),
      markLinkName: '自宅出発',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 45230,
      actions: [seedActions[4]], // 写真撮影
      createdAt: _rel(-5, 8, 0),
      updatedAt: _rel(-5, 8, 0),
    ),
    MarkLinkDomain(
      id: 'ml-002',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-5, 8, 30),
      markLinkName: '東名高速',
      members: [seedMembers[0], seedMembers[1]],
      distanceValue: 85,
      createdAt: _rel(-5, 8, 30),
      updatedAt: _rel(-5, 8, 30),
    ),
    MarkLinkDomain(
      id: 'ml-003',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-5, 10, 0),
      markLinkName: '箱根湯本駅前',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 45315,
      actions: [seedActions[0], seedActions[4]], // 観光, 写真撮影
      memo: '駅前の足湯に入った',
      createdAt: _rel(-5, 10, 0),
      updatedAt: _rel(-5, 10, 0),
    ),
    MarkLinkDomain(
      id: 'ml-004',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-5, 12, 0),
      markLinkName: '芦ノ湖スカイライン',
      members: [seedMembers[0], seedMembers[1]],
      distanceValue: 25,
      createdAt: _rel(-5, 12, 0),
      updatedAt: _rel(-5, 12, 0),
    ),
    MarkLinkDomain(
      id: 'ml-005',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-5, 13, 0),
      markLinkName: '大涌谷',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 45340,
      actions: [seedActions[0], seedActions[1], seedActions[3]], // 観光, 食事, 買い物
      memo: '黒たまごを食べた',
      isFuel: true,
      pricePerGas: 170,
      gasQuantity: 305, // 30.5L
      gasPrice: 5185,
      gasPayer: seedMembers[0],
      createdAt: _rel(-5, 13, 0),
      updatedAt: _rel(-5, 13, 0),
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
      createdAt: _rel(-5, 8, 30),
      updatedAt: _rel(-5, 8, 30),
    ),
    PaymentDomain(
      id: 'pay-002',
      paymentSeq: 2,
      paymentAmount: 2400,
      paymentMember: seedMembers[1], // 田中
      splitMembers: [seedMembers[0], seedMembers[1]],
      paymentMemo: '昼食代',
      createdAt: _rel(-5, 13, 30),
      updatedAt: _rel(-5, 13, 30),
    ),
  ],
  createdAt: _rel(-6),
  updatedAt: _rel(-5, 18, 0),
);

/// イベント2: 富士五湖キャンプ（マーク2つ、リンク1つ、支払い3つ）
final _event2 = EventDomain(
  id: 'event-002',
  eventName: '富士五湖キャンプ',
  topic: seedTopics[1], // 旅費可視化
  trans: seedTrans[0], // マイカー
  members: seedMembers, // 太郎, 田中, 鈴木
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
      paymentMember: seedMembers[2], // 鈴木
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
  topic: seedTopics[0], // 移動コスト（給油から計算）
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0]], // 太郎のみ
  tags: [seedTags[1]], // 日帰り
  createdAt: _d(2026, 3, 28, 14, 0),
  updatedAt: _d(2026, 3, 28, 16, 0),
);

/// イベント4: 燃費推定モードのサンプルイベント
final _event4 = EventDomain(
  id: 'event-004',
  eventName: '週末ドライブ（燃費推定）',
  topic: seedTopics[2], // 移動コスト（燃費で推定）
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0], seedMembers[1]], // 太郎, 田中
  tags: [seedTags[1]], // 日帰り
  kmPerGas: 155,
  pricePerGas: 175,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-009',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 5, 9, 0),
      markLinkName: '出発地点',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 46000,
      createdAt: _d(2026, 4, 5, 9, 0),
      updatedAt: _d(2026, 4, 5, 9, 0),
    ),
    MarkLinkDomain(
      id: 'ml-010',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 5, 9, 30),
      markLinkName: '一般道',
      members: [seedMembers[0], seedMembers[1]],
      distanceValue: 60,
      createdAt: _d(2026, 4, 5, 9, 30),
      updatedAt: _d(2026, 4, 5, 9, 30),
    ),
    MarkLinkDomain(
      id: 'ml-011',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 5, 11, 0),
      markLinkName: '目的地',
      members: [seedMembers[0], seedMembers[1]],
      meterValue: 46060,
      actions: [seedActions[0]], // 観光
      createdAt: _d(2026, 4, 5, 11, 0),
      updatedAt: _d(2026, 4, 5, 11, 0),
    ),
  ],
  payments: [],
  createdAt: _d(2026, 4, 5, 9, 0),
  updatedAt: _d(2026, 4, 5, 11, 0),
);

/// イベント5: 旅行計画（travelExpense・markLinksなし・TC-EAS-001用）
final _event5 = EventDomain(
  id: 'event-005',
  eventName: '旅行計画',
  topic: seedTopics[1], // 旅費可視化（travelExpense）
  trans: seedTrans[0], // マイカー
  members: seedMembers, // 太郎, 田中, 鈴木
  tags: [],
  markLinks: [],
  payments: [],
  createdAt: _d(2026, 4, 10, 9, 0),
  updatedAt: _d(2026, 4, 10, 9, 0),
);

/// イベント6: 伊豆半島ツーリング（ソロ・マーク4つ・リンク2つ・支払いなし）
final _event6 = EventDomain(
  id: 'event-006',
  eventName: '伊豆半島ツーリング',
  topic: seedTopics[3], // ツーリング
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0]], // 太郎のみ
  tags: [seedTags[3], seedTags[7]], // ツーリング, 絶景スポット
  kmPerGas: 180,
  pricePerGas: 172,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-012',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 5, 8, 0),
      markLinkName: '自宅出発',
      members: [seedMembers[0]],
      meterValue: 12000,
      createdAt: _d(2026, 4, 5, 8, 0),
      updatedAt: _d(2026, 4, 5, 8, 0),
    ),
    MarkLinkDomain(
      id: 'ml-013',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 5, 8, 30),
      markLinkName: '国道135号',
      members: [seedMembers[0]],
      distanceValue: 45,
      createdAt: _d(2026, 4, 5, 8, 30),
      updatedAt: _d(2026, 4, 5, 8, 30),
    ),
    MarkLinkDomain(
      id: 'ml-014',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 5, 9, 30),
      markLinkName: '城ヶ崎海岸',
      members: [seedMembers[0]],
      meterValue: 12045,
      actions: [seedActions[0], seedActions[4]], // 観光, 写真撮影
      memo: '吊り橋から絶景',
      createdAt: _d(2026, 4, 5, 9, 30),
      updatedAt: _d(2026, 4, 5, 9, 30),
    ),
    MarkLinkDomain(
      id: 'ml-015',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 5, 11, 0),
      markLinkName: '伊豆スカイライン',
      members: [seedMembers[0]],
      distanceValue: 38,
      createdAt: _d(2026, 4, 5, 11, 0),
      updatedAt: _d(2026, 4, 5, 11, 0),
    ),
    MarkLinkDomain(
      id: 'ml-016',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 5, 12, 0),
      markLinkName: '大室山',
      members: [seedMembers[0]],
      meterValue: 12083,
      actions: [seedActions[0]], // 観光
      isFuel: true,
      pricePerGas: 172,
      gasQuantity: 220,
      gasPrice: 3784,
      gasPayer: seedMembers[0],
      createdAt: _d(2026, 4, 5, 12, 0),
      updatedAt: _d(2026, 4, 5, 12, 0),
    ),
    MarkLinkDomain(
      id: 'ml-017',
      markLinkSeq: 6,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 5, 14, 0),
      markLinkName: '河津七滝',
      members: [seedMembers[0]],
      meterValue: 12097,
      actions: [seedActions[0], seedActions[4]], // 観光, 写真撮影
      memo: '滝の迫力がすごかった',
      createdAt: _d(2026, 4, 5, 14, 0),
      updatedAt: _d(2026, 4, 5, 14, 0),
    ),
  ],
  payments: [],
  createdAt: _d(2026, 4, 5, 8, 0),
  updatedAt: _d(2026, 4, 5, 16, 0),
);

/// イベント7: 大阪出張移動（マーク2つ・リンク1つ・支払い2つ）
final _event7 = EventDomain(
  id: 'event-007',
  eventName: '大阪出張移動',
  topic: seedTopics[4], // 仕事移動
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0], _member4], // 太郎, 鈴木さん
  tags: [seedTags[6]], // 出張
  kmPerGas: 155,
  pricePerGas: 170,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-018',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 8, 7, 0),
      markLinkName: '東京オフィス出発',
      members: [seedMembers[0], _member4],
      meterValue: 46500,
      createdAt: _d(2026, 4, 8, 7, 0),
      updatedAt: _d(2026, 4, 8, 7, 0),
    ),
    MarkLinkDomain(
      id: 'ml-019',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 8, 7, 30),
      markLinkName: '新名神高速',
      members: [seedMembers[0], _member4],
      distanceValue: 520,
      createdAt: _d(2026, 4, 8, 7, 30),
      updatedAt: _d(2026, 4, 8, 7, 30),
    ),
    MarkLinkDomain(
      id: 'ml-020',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 8, 10, 30),
      markLinkName: '名古屋SA（休憩）',
      members: [seedMembers[0], _member4],
      meterValue: 46820,
      actions: [seedActions[2]], // 休憩
      isFuel: true,
      pricePerGas: 168,
      gasQuantity: 350,
      gasPrice: 5880,
      gasPayer: seedMembers[0],
      createdAt: _d(2026, 4, 8, 10, 30),
      updatedAt: _d(2026, 4, 8, 10, 30),
    ),
    MarkLinkDomain(
      id: 'ml-021',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 8, 12, 30),
      markLinkName: '大阪クライアント先',
      members: [seedMembers[0], _member4],
      meterValue: 47020,
      actions: [seedActions[1]], // 到着 → seedActions[1]は「到着」
      memo: 'プレゼン完了',
      createdAt: _d(2026, 4, 8, 12, 30),
      updatedAt: _d(2026, 4, 8, 12, 30),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-006',
      paymentSeq: 1,
      paymentAmount: 8400,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: [seedMembers[0], _member4],
      paymentMemo: '高速道路代（往復）',
      createdAt: _d(2026, 4, 8, 7, 30),
      updatedAt: _d(2026, 4, 8, 7, 30),
    ),
    PaymentDomain(
      id: 'pay-007',
      paymentSeq: 2,
      paymentAmount: 2200,
      paymentMember: _member4, // 鈴木さん
      splitMembers: [seedMembers[0], _member4],
      paymentMemo: '昼食代',
      createdAt: _d(2026, 4, 8, 13, 0),
      updatedAt: _d(2026, 4, 8, 13, 0),
    ),
  ],
  createdAt: _d(2026, 4, 8, 7, 0),
  updatedAt: _d(2026, 4, 8, 13, 0),
);

/// イベント8: 京都一泊旅行（マーク5つ・リンク3つ・支払い4つ）
final _event8 = EventDomain(
  id: 'event-008',
  eventName: '京都一泊旅行',
  topic: seedTopics[1], // 旅費可視化
  trans: seedTrans[0], // マイカー
  members: seedMembers, // 太郎, 田中, 鈴木
  tags: [seedTags[0], seedTags[5]], // 家族旅行, グルメ
  kmPerGas: 155,
  pricePerGas: 171,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    MarkLinkDomain(
      id: 'ml-022',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 12, 7, 0),
      markLinkName: '自宅出発',
      members: seedMembers,
      meterValue: 47100,
      createdAt: _d(2026, 4, 12, 7, 0),
      updatedAt: _d(2026, 4, 12, 7, 0),
    ),
    MarkLinkDomain(
      id: 'ml-023',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 12, 7, 30),
      markLinkName: '名神高速',
      members: seedMembers,
      distanceValue: 130,
      createdAt: _d(2026, 4, 12, 7, 30),
      updatedAt: _d(2026, 4, 12, 7, 30),
    ),
    MarkLinkDomain(
      id: 'ml-024',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 12, 9, 30),
      markLinkName: '桂川PA（休憩）',
      members: seedMembers,
      meterValue: 47230,
      actions: [seedActions[2]], // 休憩
      createdAt: _d(2026, 4, 12, 9, 30),
      updatedAt: _d(2026, 4, 12, 9, 30),
    ),
    MarkLinkDomain(
      id: 'ml-025',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 12, 10, 0),
      markLinkName: '京都市内',
      members: seedMembers,
      distanceValue: 15,
      createdAt: _d(2026, 4, 12, 10, 0),
      updatedAt: _d(2026, 4, 12, 10, 0),
    ),
    MarkLinkDomain(
      id: 'ml-026',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 12, 10, 30),
      markLinkName: '金閣寺',
      members: seedMembers,
      meterValue: 47245,
      actions: [seedActions[0], seedActions[4]], // 観光, 写真撮影
      memo: '朝から混んでいた',
      createdAt: _d(2026, 4, 12, 10, 30),
      updatedAt: _d(2026, 4, 12, 10, 30),
    ),
    MarkLinkDomain(
      id: 'ml-027',
      markLinkSeq: 6,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 12, 13, 0),
      markLinkName: '嵐山竹林',
      members: seedMembers,
      meterValue: 47257,
      actions: [seedActions[0], seedActions[4]], // 観光, 写真撮影
      memo: 'ランチは嵐山で',
      createdAt: _d(2026, 4, 12, 13, 0),
      updatedAt: _d(2026, 4, 12, 13, 0),
    ),
    MarkLinkDomain(
      id: 'ml-028',
      markLinkSeq: 7,
      markLinkType: MarkOrLink.link,
      markLinkDate: _d(2026, 4, 12, 16, 0),
      markLinkName: '京都駅方面',
      members: seedMembers,
      distanceValue: 8,
      createdAt: _d(2026, 4, 12, 16, 0),
      updatedAt: _d(2026, 4, 12, 16, 0),
    ),
    MarkLinkDomain(
      id: 'ml-029',
      markLinkSeq: 8,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _d(2026, 4, 12, 17, 0),
      markLinkName: 'ホテル着（京都駅前）',
      members: seedMembers,
      meterValue: 47265,
      isFuel: true,
      pricePerGas: 171,
      gasQuantity: 280,
      gasPrice: 4788,
      gasPayer: seedMembers[0],
      memo: 'チェックイン完了',
      createdAt: _d(2026, 4, 12, 17, 0),
      updatedAt: _d(2026, 4, 12, 17, 0),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-008',
      paymentSeq: 1,
      paymentAmount: 9600,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: seedMembers,
      paymentMemo: '高速道路代（往復）',
      createdAt: _d(2026, 4, 12, 7, 30),
      updatedAt: _d(2026, 4, 12, 7, 30),
    ),
    PaymentDomain(
      id: 'pay-009',
      paymentSeq: 2,
      paymentAmount: 18000,
      paymentMember: seedMembers[1], // 田中
      splitMembers: seedMembers,
      paymentMemo: 'ホテル代',
      createdAt: _d(2026, 4, 12, 17, 0),
      updatedAt: _d(2026, 4, 12, 17, 0),
    ),
    PaymentDomain(
      id: 'pay-010',
      paymentSeq: 3,
      paymentAmount: 7200,
      paymentMember: seedMembers[2], // 鈴木
      splitMembers: seedMembers,
      paymentMemo: '夕食代（懐石）',
      createdAt: _d(2026, 4, 12, 19, 0),
      updatedAt: _d(2026, 4, 12, 19, 0),
    ),
    PaymentDomain(
      id: 'pay-011',
      paymentSeq: 4,
      paymentAmount: 3600,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: seedMembers,
      paymentMemo: '観光施設入場料合計',
      createdAt: _d(2026, 4, 12, 15, 0),
      updatedAt: _d(2026, 4, 12, 15, 0),
    ),
  ],
  createdAt: _d(2026, 4, 12, 7, 0),
  updatedAt: _d(2026, 4, 13, 18, 0),
);

/// テスト用シードイベント（現行 event-001〜008 をそのまま維持）
final _testSeedEvents = [
  _event1,
  _event2,
  _event3,
  _event4,
  _event5,
  _event6,
  _event7,
  _event8,
];

// ---------------------------------------------------------------------------
// 本番用シードデータ（シナリオA・B・C）
// ---------------------------------------------------------------------------

/// シナリオA: 箱根日帰りドライブ
/// movingCost トピック・3名・11 MarkLink・4 Payment・給油1回
final _eventSeedA = EventDomain(
  id: 'event-seed-a',
  eventName: '箱根日帰りドライブ',
  topic: seedTopics[0], // 移動コスト（給油から計算）
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0], seedMembers[1], seedMembers[2]], // 太郎・田中・鈴木
  tags: [seedTags[1]], // 日帰り
  kmPerGas: 155,
  pricePerGas: 175,
  payMember: seedMembers[0], // 太郎
  markLinks: [
    // seq 1: 自宅出発（mark）
    MarkLinkDomain(
      id: 'ml-sa-001',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-7, 8, 0),
      markLinkName: '自宅出発',
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      meterValue: 45000,
      createdAt: _rel(-7, 8, 0),
      updatedAt: _rel(-7, 8, 0),
    ),
    // seq 2: 足柄SA方面（link）
    MarkLinkDomain(
      id: 'ml-sa-002',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-7, 8, 30),
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      distanceValue: 65,
      createdAt: _rel(-7, 8, 30),
      updatedAt: _rel(-7, 8, 30),
    ),
    // seq 3: 足柄SA（mark・給油）
    MarkLinkDomain(
      id: 'ml-sa-003',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-7, 9, 30),
      markLinkName: '足柄SA',
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      meterValue: 45065,
      isFuel: true,
      pricePerGas: 175,
      gasQuantity: 350, // 35.0L
      gasPrice: 6125,
      gasPayer: seedMembers[0],
      createdAt: _rel(-7, 9, 30),
      updatedAt: _rel(-7, 9, 30),
    ),
    // seq 4: 箱根神社方面（link）
    MarkLinkDomain(
      id: 'ml-sa-004',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-7, 10, 0),
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      distanceValue: 20,
      createdAt: _rel(-7, 10, 0),
      updatedAt: _rel(-7, 10, 0),
    ),
    // seq 5: 箱根神社（mark・観光）
    MarkLinkDomain(
      id: 'ml-sa-005',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-7, 11, 0),
      markLinkName: '箱根神社',
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      meterValue: 45085,
      actions: [seedActions[2]], // 観光（action-001）
      createdAt: _rel(-7, 11, 0),
      updatedAt: _rel(-7, 11, 0),
    ),
    // seq 6: 大涌谷方面（link）
    MarkLinkDomain(
      id: 'ml-sa-006',
      markLinkSeq: 6,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-7, 11, 30),
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      distanceValue: 8,
      createdAt: _rel(-7, 11, 30),
      updatedAt: _rel(-7, 11, 30),
    ),
    // seq 7: 大涌谷（mark・観光）
    MarkLinkDomain(
      id: 'ml-sa-007',
      markLinkSeq: 7,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-7, 12, 0),
      markLinkName: '大涌谷',
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      meterValue: 45093,
      actions: [seedActions[2]], // 観光（action-001）
      createdAt: _rel(-7, 12, 0),
      updatedAt: _rel(-7, 12, 0),
    ),
    // seq 8: 箱根湯本方面（link）
    MarkLinkDomain(
      id: 'ml-sa-008',
      markLinkSeq: 8,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-7, 12, 30),
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      distanceValue: 12,
      createdAt: _rel(-7, 12, 30),
      updatedAt: _rel(-7, 12, 30),
    ),
    // seq 9: 箱根湯本（昼食）（mark・食事）
    MarkLinkDomain(
      id: 'ml-sa-009',
      markLinkSeq: 9,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-7, 13, 0),
      markLinkName: '箱根湯本（昼食）',
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      meterValue: 45105,
      actions: [seedActions[3]], // 食事（action-002）
      createdAt: _rel(-7, 13, 0),
      updatedAt: _rel(-7, 13, 0),
    ),
    // seq 10: 帰路（link）
    MarkLinkDomain(
      id: 'ml-sa-010',
      markLinkSeq: 10,
      markLinkType: MarkOrLink.link,
      markLinkDate: _rel(-7, 14, 30),
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      distanceValue: 85,
      createdAt: _rel(-7, 14, 30),
      updatedAt: _rel(-7, 14, 30),
    ),
    // seq 11: 帰宅（mark）
    MarkLinkDomain(
      id: 'ml-sa-011',
      markLinkSeq: 11,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-7, 17, 0),
      markLinkName: '帰宅',
      members: [seedMembers[0], seedMembers[1], seedMembers[2]],
      meterValue: 45190,
      createdAt: _rel(-7, 17, 0),
      updatedAt: _rel(-7, 17, 0),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-seed-a1',
      paymentSeq: 1,
      paymentAmount: 3200,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: [seedMembers[0], seedMembers[1], seedMembers[2]],
      paymentMemo: '高速代（往復）',
      createdAt: _rel(-7, 8, 30),
      updatedAt: _rel(-7, 8, 30),
    ),
    PaymentDomain(
      id: 'pay-seed-a2',
      paymentSeq: 2,
      paymentAmount: 4500,
      paymentMember: seedMembers[0], // 太郎
      splitMembers: [seedMembers[0], seedMembers[1], seedMembers[2]],
      paymentMemo: 'ガソリン代',
      createdAt: _rel(-7, 9, 30),
      updatedAt: _rel(-7, 9, 30),
    ),
    PaymentDomain(
      id: 'pay-seed-a3',
      paymentSeq: 3,
      paymentAmount: 8700,
      paymentMember: seedMembers[1], // 田中
      splitMembers: [seedMembers[0], seedMembers[1], seedMembers[2]],
      paymentMemo: '昼食',
      createdAt: _rel(-7, 13, 30),
      updatedAt: _rel(-7, 13, 30),
    ),
    PaymentDomain(
      id: 'pay-seed-a4',
      paymentSeq: 4,
      paymentAmount: 1000,
      paymentMember: seedMembers[2], // 鈴木
      splitMembers: [seedMembers[0], seedMembers[1], seedMembers[2]],
      paymentMemo: '駐車場',
      createdAt: _rel(-7, 11, 0),
      updatedAt: _rel(-7, 11, 0),
    ),
  ],
  createdAt: _rel(-7, 8, 0),
  updatedAt: _rel(-7, 17, 0),
);

/// シナリオB: 4月 業務走行記録
/// movingCost トピック・1名・9 MarkLink・2 Payment・給油2回
final _eventSeedB = EventDomain(
  id: 'event-seed-b',
  eventName: '4月 業務走行記録',
  topic: seedTopics[0], // 移動コスト（給油から計算）
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0]], // 太郎のみ
  tags: [],
  kmPerGas: 155,
  pricePerGas: 173,
  payMember: seedMembers[0],
  markLinks: [
    // seq 1: 当月1日（link・42km）
    MarkLinkDomain(
      id: 'ml-sb-001',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.link,
      markLinkDate: _monthStart(1, 8, 0),
      members: [seedMembers[0]],
      distanceValue: 42,
      createdAt: _monthStart(1, 8, 0),
      updatedAt: _monthStart(1, 8, 0),
    ),
    // seq 2: 当月3日（mark・給油: 40L, 172円/L, 6880円）
    MarkLinkDomain(
      id: 'ml-sb-002',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _monthStart(3, 9, 0),
      members: [seedMembers[0]],
      isFuel: true,
      pricePerGas: 172,
      gasQuantity: 400, // 40.0L
      gasPrice: 6880,
      gasPayer: seedMembers[0],
      createdAt: _monthStart(3, 9, 0),
      updatedAt: _monthStart(3, 9, 0),
    ),
    // seq 3: 当月3日（link・87km）
    MarkLinkDomain(
      id: 'ml-sb-003',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.link,
      markLinkDate: _monthStart(3, 10, 0),
      members: [seedMembers[0]],
      distanceValue: 87,
      createdAt: _monthStart(3, 10, 0),
      updatedAt: _monthStart(3, 10, 0),
    ),
    // seq 4: 当月7日（mark）
    MarkLinkDomain(
      id: 'ml-sb-004',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _monthStart(7, 9, 0),
      members: [seedMembers[0]],
      createdAt: _monthStart(7, 9, 0),
      updatedAt: _monthStart(7, 9, 0),
    ),
    // seq 5: 当月7日（link・38km）
    MarkLinkDomain(
      id: 'ml-sb-005',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.link,
      markLinkDate: _monthStart(7, 10, 0),
      members: [seedMembers[0]],
      distanceValue: 38,
      createdAt: _monthStart(7, 10, 0),
      updatedAt: _monthStart(7, 10, 0),
    ),
    // seq 6: 当月10日（mark・給油: 45L, 174円/L, 7830円）
    MarkLinkDomain(
      id: 'ml-sb-006',
      markLinkSeq: 6,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _monthStart(10, 9, 0),
      members: [seedMembers[0]],
      isFuel: true,
      pricePerGas: 174,
      gasQuantity: 450, // 45.0L
      gasPrice: 7830,
      gasPayer: seedMembers[0],
      createdAt: _monthStart(10, 9, 0),
      updatedAt: _monthStart(10, 9, 0),
    ),
    // seq 7: 当月10日（link・112km）
    MarkLinkDomain(
      id: 'ml-sb-007',
      markLinkSeq: 7,
      markLinkType: MarkOrLink.link,
      markLinkDate: _monthStart(10, 10, 0),
      members: [seedMembers[0]],
      distanceValue: 112,
      createdAt: _monthStart(10, 10, 0),
      updatedAt: _monthStart(10, 10, 0),
    ),
    // seq 8: 当月14日（mark）
    MarkLinkDomain(
      id: 'ml-sb-008',
      markLinkSeq: 8,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _monthStart(14, 9, 0),
      members: [seedMembers[0]],
      createdAt: _monthStart(14, 9, 0),
      updatedAt: _monthStart(14, 9, 0),
    ),
    // seq 9: 当月14日（link・55km）
    MarkLinkDomain(
      id: 'ml-sb-009',
      markLinkSeq: 9,
      markLinkType: MarkOrLink.link,
      markLinkDate: _monthStart(14, 10, 0),
      members: [seedMembers[0]],
      distanceValue: 55,
      createdAt: _monthStart(14, 10, 0),
      updatedAt: _monthStart(14, 10, 0),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-seed-b1',
      paymentSeq: 1,
      paymentAmount: 6880,
      paymentMember: seedMembers[0],
      splitMembers: [seedMembers[0]],
      paymentMemo: 'ガソリン代（当月3日）',
      createdAt: _monthStart(3, 9, 0),
      updatedAt: _monthStart(3, 9, 0),
    ),
    PaymentDomain(
      id: 'pay-seed-b2',
      paymentSeq: 2,
      paymentAmount: 7830,
      paymentMember: seedMembers[0],
      splitMembers: [seedMembers[0]],
      paymentMemo: 'ガソリン代（当月10日）',
      createdAt: _monthStart(10, 9, 0),
      updatedAt: _monthStart(10, 9, 0),
    ),
  ],
  createdAt: _monthStart(1, 8, 0),
  updatedAt: _monthStart(14, 17, 0),
);

/// シナリオC: 横浜エリア訪問ルート
/// visitWork トピック・1名・5 MarkLink・3 Payment
/// B-19: Link 4件を削除（visitWorkトピックは区間を作成しない仕様）
final _eventSeedC = EventDomain(
  id: 'event-seed-c',
  eventName: '横浜エリア訪問ルート',
  topic: seedTopics[5], // 訪問作業（topic_visit_work）
  trans: seedTrans[0], // マイカー
  members: [seedMembers[0]], // 太郎のみ
  tags: [],
  payMember: seedMembers[0],
  markLinks: [
    // seq 1: 事務所出発（mark・visit_work_depart）
    MarkLinkDomain(
      id: 'ml-sc-001',
      markLinkSeq: 1,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-3, 9, 0),
      markLinkName: '事務所出発',
      members: [seedMembers[0]],
      actions: [seedActions[8]], // visit_work_depart
      createdAt: _rel(-3, 9, 0),
      updatedAt: _rel(-3, 9, 0),
    ),
    // seq 2: A社（横浜駅前）（mark・到着・作業開始・作業終了）
    MarkLinkDomain(
      id: 'ml-sc-003',
      markLinkSeq: 2,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-3, 10, 0),
      markLinkName: 'A社（横浜駅前）',
      members: [seedMembers[0]],
      actions: [
        seedActions[7],  // visit_work_arrive
        seedActions[9],  // visit_work_start
        seedActions[10], // visit_work_end
      ],
      createdAt: _rel(-3, 10, 0),
      updatedAt: _rel(-3, 10, 0),
    ),
    // seq 3: B社（みなとみらい）（mark・到着・作業開始・休憩・作業終了）
    MarkLinkDomain(
      id: 'ml-sc-005',
      markLinkSeq: 3,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-3, 11, 5),
      markLinkName: 'B社（みなとみらい）',
      members: [seedMembers[0]],
      actions: [
        seedActions[7],  // visit_work_arrive
        seedActions[9],  // visit_work_start
        seedActions[11], // visit_work_break
        seedActions[10], // visit_work_end
      ],
      createdAt: _rel(-3, 11, 5),
      updatedAt: _rel(-3, 11, 5),
    ),
    // seq 4: C社（磯子）（mark・到着・作業開始・作業終了）
    MarkLinkDomain(
      id: 'ml-sc-007',
      markLinkSeq: 4,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-3, 14, 50),
      markLinkName: 'C社（磯子）',
      members: [seedMembers[0]],
      actions: [
        seedActions[7],  // visit_work_arrive
        seedActions[9],  // visit_work_start
        seedActions[10], // visit_work_end
      ],
      createdAt: _rel(-3, 14, 50),
      updatedAt: _rel(-3, 14, 50),
    ),
    // seq 5: 事務所帰着（mark・visit_work_arrive）
    MarkLinkDomain(
      id: 'ml-sc-009',
      markLinkSeq: 5,
      markLinkType: MarkOrLink.mark,
      markLinkDate: _rel(-3, 17, 30),
      markLinkName: '事務所帰着',
      members: [seedMembers[0]],
      actions: [seedActions[7]], // visit_work_arrive
      createdAt: _rel(-3, 17, 30),
      updatedAt: _rel(-3, 17, 30),
    ),
  ],
  payments: [
    PaymentDomain(
      id: 'pay-seed-c1',
      paymentSeq: 1,
      paymentAmount: 500,
      paymentMember: seedMembers[0],
      splitMembers: [seedMembers[0]],
      paymentMemo: '駐車場（A社）',
      createdAt: _rel(-3, 10, 0),
      updatedAt: _rel(-3, 10, 0),
    ),
    PaymentDomain(
      id: 'pay-seed-c2',
      paymentSeq: 2,
      paymentAmount: 800,
      paymentMember: seedMembers[0],
      splitMembers: [seedMembers[0]],
      paymentMemo: '駐車場（B社）',
      createdAt: _rel(-3, 12, 30),
      updatedAt: _rel(-3, 12, 30),
    ),
    PaymentDomain(
      id: 'pay-seed-c3',
      paymentSeq: 3,
      paymentAmount: 950,
      paymentMember: seedMembers[0],
      splitMembers: [seedMembers[0]],
      paymentMemo: '昼食',
      createdAt: _rel(-3, 13, 0),
      updatedAt: _rel(-3, 13, 0),
    ),
  ],
  // B-20: ActionTimeLog 11件追加（A社3件・B社5件・C社3件）
  actionTimeLogs: [
    // A社（横浜駅前）: 到着09:15・作業開始09:20・作業終了10:45
    ActionTimeLog(
      id: 'actiontime-seed-c-a1',
      eventId: 'event-seed-c',
      actionId: 'visit_work_arrive',
      timestamp: _rel(-3, 9, 15),
      createdAt: _rel(-3, 9, 15),
      updatedAt: _rel(-3, 9, 15),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-a2',
      eventId: 'event-seed-c',
      actionId: 'visit_work_start',
      timestamp: _rel(-3, 9, 20),
      createdAt: _rel(-3, 9, 20),
      updatedAt: _rel(-3, 9, 20),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-a3',
      eventId: 'event-seed-c',
      actionId: 'visit_work_end',
      timestamp: _rel(-3, 10, 45),
      createdAt: _rel(-3, 10, 45),
      updatedAt: _rel(-3, 10, 45),
    ),
    // B社（みなとみらい）: 到着11:05・作業開始11:10・休憩12:00・作業再開13:00・作業終了14:20
    ActionTimeLog(
      id: 'actiontime-seed-c-b1',
      eventId: 'event-seed-c',
      actionId: 'visit_work_arrive',
      timestamp: _rel(-3, 11, 5),
      createdAt: _rel(-3, 11, 5),
      updatedAt: _rel(-3, 11, 5),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-b2',
      eventId: 'event-seed-c',
      actionId: 'visit_work_start',
      timestamp: _rel(-3, 11, 10),
      createdAt: _rel(-3, 11, 10),
      updatedAt: _rel(-3, 11, 10),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-b3',
      eventId: 'event-seed-c',
      actionId: 'visit_work_break',
      timestamp: _rel(-3, 12, 0),
      createdAt: _rel(-3, 12, 0),
      updatedAt: _rel(-3, 12, 0),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-b4',
      eventId: 'event-seed-c',
      actionId: 'visit_work_start',
      timestamp: _rel(-3, 13, 0),
      createdAt: _rel(-3, 13, 0),
      updatedAt: _rel(-3, 13, 0),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-b5',
      eventId: 'event-seed-c',
      actionId: 'visit_work_end',
      timestamp: _rel(-3, 14, 20),
      createdAt: _rel(-3, 14, 20),
      updatedAt: _rel(-3, 14, 20),
    ),
    // C社（磯子）: 到着14:50・作業開始14:55・作業終了16:10
    ActionTimeLog(
      id: 'actiontime-seed-c-c1',
      eventId: 'event-seed-c',
      actionId: 'visit_work_arrive',
      timestamp: _rel(-3, 14, 50),
      createdAt: _rel(-3, 14, 50),
      updatedAt: _rel(-3, 14, 50),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-c2',
      eventId: 'event-seed-c',
      actionId: 'visit_work_start',
      timestamp: _rel(-3, 14, 55),
      createdAt: _rel(-3, 14, 55),
      updatedAt: _rel(-3, 14, 55),
    ),
    ActionTimeLog(
      id: 'actiontime-seed-c-c3',
      eventId: 'event-seed-c',
      actionId: 'visit_work_end',
      timestamp: _rel(-3, 16, 10),
      createdAt: _rel(-3, 16, 10),
      updatedAt: _rel(-3, 16, 10),
    ),
  ],
  createdAt: _rel(-3, 8, 0),
  updatedAt: _rel(-3, 17, 30),
);

/// 本番用シードイベント（シナリオA・B・C の3件）
final _prodSeedEvents = [_eventSeedA, _eventSeedB, _eventSeedC];

// ---------------------------------------------------------------------------
// 公開変数（di.dart から参照）
// FLAVOR dart-define でテスト用/本番用を自動切替
// FLAVOR=prod（本番ビルド）→ 本番用シードデータ（シナリオA・B・C）
// FLAVOR=dev / 未指定（開発・Integration Test）→ テスト用シードデータ（event-001〜008）
// ---------------------------------------------------------------------------

const _seedFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
final seedEvents = _seedFlavor == 'prod' ? _prodSeedEvents : _testSeedEvents;
