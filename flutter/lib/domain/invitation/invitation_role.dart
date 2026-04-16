/// ユーザーのイベント内での権限を表す。
enum InvitationRole {
  /// イベント作成者
  owner,

  /// 編集権限を持つ参加者
  editor,

  /// 閲覧権限のみの参加者
  viewer,
}
