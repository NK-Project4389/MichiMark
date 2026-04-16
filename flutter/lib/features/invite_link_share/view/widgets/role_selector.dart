import 'package:flutter/material.dart';

import '../../draft/invite_link_share_draft.dart';

/// 権限選択（Radio）Widget。
class RoleSelector extends StatelessWidget {
  final InviteLinkRole selectedRole;
  final ValueChanged<InviteLinkRole> onChanged;
  final bool enabled;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '権限',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        RadioGroup<InviteLinkRole>(
          groupValue: selectedRole,
          onChanged: (InviteLinkRole? value) {
            if (enabled && value != null) onChanged(value);
          },
          child: Column(
            children: [
              RadioListTile<InviteLinkRole>(
                key: const Key('inviteLinkShare_radio_editor'),
                title: Text(InviteLinkRole.editor.displayLabel),
                value: InviteLinkRole.editor,
              ),
              RadioListTile<InviteLinkRole>(
                key: const Key('inviteLinkShare_radio_viewer'),
                title: Text(InviteLinkRole.viewer.displayLabel),
                value: InviteLinkRole.viewer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
