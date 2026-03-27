import 'package:equatable/equatable.dart';

sealed class SelectionEvent extends Equatable {
  const SelectionEvent();
}

/// 画面が表示されたとき（候補リストを取得する）
class SelectionStarted extends SelectionEvent {
  const SelectionStarted();

  @override
  List<Object?> get props => [];
}

/// アイテムがタップされたとき
class SelectionItemToggled extends SelectionEvent {
  final String id;
  const SelectionItemToggled(this.id);

  @override
  List<Object?> get props => [id];
}

/// 確定ボタンが押されたとき
class SelectionConfirmed extends SelectionEvent {
  const SelectionConfirmed();

  @override
  List<Object?> get props => [];
}

/// キャンセル（戻る）が押されたとき
class SelectionDismissed extends SelectionEvent {
  const SelectionDismissed();

  @override
  List<Object?> get props => [];
}
