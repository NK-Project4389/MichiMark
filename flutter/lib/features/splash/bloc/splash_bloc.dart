import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// スプラッシュ画面のBloC。
///
/// - [SplashStarted] を受け取り、最低表示時間（1秒）と DI初期化完了確認を並列実行する。
/// - 両条件が揃ったタイミングで [SplashInitializationCompleted] を発火し、
///   [SplashCompleted] に遷移してDelegateをセットする。
/// - context.go() 等の直接ナビゲーション操作は禁止。
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashInitializationCompleted>(_onSplashInitializationCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashAnimating());

    // タイマー（最低1秒）と DI初期化確認を並列実行する。
    // setupDi() は同期完了しているため、DI確認は即時OK。
    await Future.wait([
      Future<void>.delayed(const Duration(seconds: 1)),
      // GetItのDI登録済み確認（同期完了済みのため即時Future）
      Future<void>.value(),
    ]);

    add(const SplashInitializationCompleted());
  }

  void _onSplashInitializationCompleted(
    SplashInitializationCompleted event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashCompleted(
      delegate: SplashNavigateToDashboardDelegate(),
    ));
  }
}
