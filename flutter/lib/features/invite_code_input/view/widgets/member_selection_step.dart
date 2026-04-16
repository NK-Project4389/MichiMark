import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/invite_code_input_bloc.dart';
import '../../bloc/invite_code_input_event.dart';
import '../../bloc/invite_code_input_state.dart';
import '../../domain/invite_code_member_item.dart';

class MemberSelectionStep extends StatelessWidget {
  final InviteCodeInputMemberSelection state;

  const MemberSelectionStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isJoinEnabled = state.selectedMemberId != null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.eventName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'あなたはどのメンバーですか？',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: state.selectedMemberId,
            onChanged: (value) {
              if (value == null) return;
              context
                  .read<InviteCodeInputBloc>()
                  .add(InviteCodeMemberSelected(value));
            },
            child: Column(
              children: state.members
                  .map((member) => _MemberRadioTile(member: member))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('invite_code_join_button'),
            onPressed: isJoinEnabled
                ? () => context
                    .read<InviteCodeInputBloc>()
                    .add(const InviteCodeJoinConfirmed())
                : null,
            child: const Text('参加する'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context
                .read<InviteCodeInputBloc>()
                .add(const InviteCodeBackToInput()),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}

class _MemberRadioTile extends StatelessWidget {
  final InviteCodeMemberItem member;

  const _MemberRadioTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      key: Key('member_radio_${member.memberId}'),
      title: Text(member.memberName),
      value: member.memberId,
    );
  }
}
