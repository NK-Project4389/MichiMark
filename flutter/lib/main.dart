import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'firebase/firebase_options_dev.dart' as dev_options;
import 'firebase/firebase_options_prod.dart' as prod_options;
import 'repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isTest = Platform.environment.containsKey('FLUTTER_TEST');

  if (!isTest) {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    final options = flavor == 'prod'
        ? prod_options.DefaultFirebaseOptions.currentPlatform
        : dev_options.DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
  }

  setupDi();

  if (!isTest) {
    final authRepository = getIt<AuthRepository>();
    if (authRepository.currentUid == null) {
      try {
        await authRepository.signInAnonymously();
      } catch (_) {
        // オフラインキャッシュモードで動作継続
      }
    }
  }

  runApp(const MichiMarkApp());
}
