import 'package:flutter/material.dart';
import 'router.dart';

class MichiMarkApp extends StatelessWidget {
  const MichiMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MichiMark',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
