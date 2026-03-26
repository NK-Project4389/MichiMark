import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/basic_info_bloc.dart';
import '../bloc/basic_info_event.dart';
import '../bloc/basic_info_state.dart';
import '../draft/basic_info_draft.dart';

class BasicInfoView extends StatelessWidget {
  const BasicInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BasicInfoBloc, BasicInfoState>(
      listener: (context, state) {
        if (state is BasicInfoLoaded && state.delegate != null) {
          _handleDelegate(context, state.delegate!);
        }
      },
      builder: (context, state) {
        return switch (state) {
          BasicInfoLoading() => const Center(child: CircularProgressIndicator()),
          BasicInfoError(:final message) => Center(child: Text(message)),
          BasicInfoLoaded(:final draft) => _BasicInfoForm(draft: draft),
        };
      },
    );
  }

  void _handleDelegate(BuildContext context, BasicInfoDelegate delegate) {
    switch (delegate) {
      case BasicInfoOpenTransSelectionDelegate():
        // TODO: context.go('/selection/trans') — 交通手段選択画面（未実装）
        break;
      case BasicInfoOpenMembersSelectionDelegate():
        // TODO: context.go('/selection/members') — メンバー選択画面（未実装）
        break;
      case BasicInfoOpenTagsSelectionDelegate():
        // TODO: context.go('/selection/tags') — タグ選択画面（未実装）
        break;
      case BasicInfoOpenPayMemberSelectionDelegate():
        // TODO: context.go('/selection/pay-member') — 支払メンバー選択画面（未実装）
        break;
    }
  }
}

class _BasicInfoForm extends StatelessWidget {
  final BasicInfoDraft draft;

  const _BasicInfoForm({required this.draft});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _EventNameField(value: draft.eventName),
        const SizedBox(height: 16),
        _SelectionRow(
          label: '交通手段',
          value: draft.selectedTrans?.transName ?? '未選択',
          onEditPressed: () => context
              .read<BasicInfoBloc>()
              .add(const BasicInfoEditTransPressed()),
        ),
        const SizedBox(height: 16),
        _NumberInputField(
          label: '燃費 (km/L)',
          value: draft.kmPerGasInput,
          onChanged: (input) => context
              .read<BasicInfoBloc>()
              .add(BasicInfoKmPerGasChanged(input)),
        ),
        const SizedBox(height: 16),
        _NumberInputField(
          label: 'ガソリン単価 (円/L)',
          value: draft.pricePerGasInput,
          onChanged: (input) => context
              .read<BasicInfoBloc>()
              .add(BasicInfoPricePerGasChanged(input)),
        ),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'メンバー',
          value: draft.selectedMembers.isEmpty
              ? '未選択'
              : draft.selectedMembers.map((m) => m.memberName).join('、'),
          onEditPressed: () => context
              .read<BasicInfoBloc>()
              .add(const BasicInfoEditMembersPressed()),
        ),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'タグ',
          value: draft.selectedTags.isEmpty
              ? '未選択'
              : draft.selectedTags.map((t) => t.tagName).join('、'),
          onEditPressed: () => context
              .read<BasicInfoBloc>()
              .add(const BasicInfoEditTagsPressed()),
        ),
        const SizedBox(height: 16),
        _SelectionRow(
          label: 'ガソリン支払者',
          value: draft.selectedPayMember?.memberName ?? '未選択',
          onEditPressed: () => context
              .read<BasicInfoBloc>()
              .add(const BasicInfoEditPayMemberPressed()),
        ),
      ],
    );
  }
}

class _EventNameField extends StatefulWidget {
  final String value;

  const _EventNameField({required this.value});

  @override
  State<_EventNameField> createState() => _EventNameFieldState();
}

class _EventNameFieldState extends State<_EventNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'イベント名',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => context
          .read<BasicInfoBloc>()
          .add(BasicInfoEventNameChanged(value)),
    );
  }
}

class _NumberInputField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _NumberInputField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<_NumberInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: widget.onChanged,
    );
  }
}

class _SelectionRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEditPressed;

  const _SelectionRow({
    required this.label,
    required this.value,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}
