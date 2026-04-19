import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// スプラッシュ画面の initState で発火するイベント。
/// アニメーション開始 + DI初期化完了待機を開始する。
class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// DI初期化完了 AND 最低表示時間経過の両方が揃ったときにBloc内部で発火する。
class SplashInitializationCompleted extends SplashEvent {
  const SplashInitializationCompleted();
}
