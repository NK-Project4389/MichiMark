import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/invite_code_input_bloc.dart';
import '../bloc/invite_code_input_event.dart';
import '../bloc/invite_code_input_state.dart';
import 'widgets/code_input_step.dart';
import 'widgets/error_view.dart';
import 'widgets/member_selection_step.dart';

class InviteCodeInputView extends StatelessWidget {
  const InviteCodeInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InviteCodeInputBloc, InviteCodeInputState>(
      listener: (context, state) {
        if (state is InviteCodeInputJoined) {
          _showSuccessDialog(context, state.eventId, state.eventName);
        }
      },
      builder: (context, state) {
        return switch (state) {
          InviteCodeInputInitial() => _buildInitialView(context, state),
          InviteCodeInputValidating() => _buildLoading(),
          InviteCodeInputMemberSelection() =>
            _buildMemberSelectionView(context, state),
          InviteCodeInputJoining() => _buildLoading(),
          InviteCodeInputJoined() => _buildLoading(),
          InviteCodeInputError() => _buildErrorView(context, state),
        };
      },
    );
  }

  Widget _buildInitialView(BuildContext context, InviteCodeInputInitial state) {
    return SingleChildScrollView(
      child: CodeInputStep(state: state),
    );
  }

  Widget _buildMemberSelectionView(
    BuildContext context,
    InviteCodeInputMemberSelection state,
  ) {
    return SingleChildScrollView(
      child: MemberSelectionStep(state: state),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView(
    BuildContext context,
    InviteCodeInputError state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InviteCodeErrorView(errorType: state.errorType),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context
                .read<InviteCodeInputBloc>()
                .add(const InviteCodeBackToInput()),
            child: const Text('最初からやり直す'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    String eventId,
    String eventName,
  ) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('参加完了'),
        content: Text('「$eventName」に参加しました！'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (!context.mounted) return;
              context.go('/event/$eventId');
            },
          ),
        ],
      ),
    );
  }
}
