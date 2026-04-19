import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// Delegate
// ---------------------------------------------------------------------------

/// スプラッシュ画面からの遷移意図を表すDelegateの基底クラス。
abstract class SplashDelegate extends Equatable {
  const SplashDelegate();
}

/// Dashboardへ遷移することを示すDelegate。
class SplashNavigateToDashboardDelegate extends SplashDelegate {
  const SplashNavigateToDashboardDelegate();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// スプラッシュ画面の状態を表すsealed class相当の基底クラス。
/// Specに従い Draft / Projection / Adapter の三層は省略する。
sealed class SplashState extends Equatable {
  const SplashState();
}

/// 初期状態
class SplashInitial extends SplashState {
  const SplashInitial();

  @override
  List<Object?> get props => [];
}

/// アニメーション再生中
class SplashAnimating extends SplashState {
  const SplashAnimating();

  @override
  List<Object?> get props => [];
}

/// 初期化完了・遷移準備完了
class SplashCompleted extends SplashState {
  final SplashDelegate? delegate;

  const SplashCompleted({this.delegate});

  @override
  List<Object?> get props => [delegate];
}
