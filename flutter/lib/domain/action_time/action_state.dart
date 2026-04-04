/// ActionTimeの状態種別enum。
/// Domain層に定義する（UIは知らない）。
/// Projectionで表示文字列に変換する。
enum ActionState {
  /// 移動前・終了後の滞留状態
  waiting,

  /// 走行中
  moving,

  /// 訪問先での作業中
  working,

  /// 一時中断（休憩）。作業中のトグル状態
  // ignore: constant_identifier_names
  break_,
}

extension ActionStateLabel on ActionState {
  String get label => switch (this) {
        ActionState.waiting => '待機中',
        ActionState.moving => '移動中',
        ActionState.working => '作業中',
        ActionState.break_ => '休憩中',
      };
}
