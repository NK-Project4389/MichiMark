import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

/// スプラッシュ画面のロゴアセットパス。
/// デザイン確認後に白抜きロゴへ差し替え予定。
const _kSplashLogoAsset = 'assets/images/splash_logo.png';

/// スプラッシュ画面の背景色（アイコンの薄青カラー）。
const _kSplashBackgroundColor = Color(0xFFA8D4E6);

/// アニメーション時間（フェードイン + スケールアップ）
const _kAnimationDuration = Duration(milliseconds: 1500);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // SplashStarted を発火してタイマー + DI確認を開始する
    context.read<SplashBloc>().add(const SplashStarted());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          final delegate = state.delegate;
          if (delegate is SplashNavigateToDashboardDelegate) {
            context.go('/dashboard');
          }
        }
      },
      child: Scaffold(
        backgroundColor: _kSplashBackgroundColor,
        body: Container(
          key: const Key('splash_container_background'),
          color: _kSplashBackgroundColor,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  _kSplashLogoAsset,
                  key: const Key('splash_image_logo'),
                  width: 160,
                  height: 160,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
