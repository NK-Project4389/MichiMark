import 'package:flutter/material.dart';
import 'invite_code_input_view.dart';

class InviteCodeInputPage extends StatelessWidget {
  const InviteCodeInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('招待コードで参加'),
        centerTitle: true,
      ),
      body: const InviteCodeInputView(),
    );
  }
}
