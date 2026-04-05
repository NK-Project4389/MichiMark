import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/basic_info_bloc.dart';
import '../bloc/basic_info_event.dart';
import '../bloc/basic_info_state.dart';
import '../draft/basic_info_draft.dart';

/// BasicInfo タブの編集View。
/// await context.push を使うため StatefulWidget とする（mounted チェック必須）。
class BasicInfoView extends StatefulWidget {
  const BasicInfoView({super.key});

  @override
  State<BasicInfoView> createState() => _BasicInfoViewState();
}

class _BasicInfoViewState extends State<BasicInfoView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BasicInfoBloc, BasicInfoState>(
      listener: (context, state) async {
        if (state is BasicInfoLoaded && state.delegate != null) {
          await _handleDelegate(state.delegate!, state.draft);
        }
      },
      builder: (context, state) {
        return switch (state) {
          BasicInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          BasicInfoError(:final message) => Center(child: Text(message)),
          BasicInfoLoaded(:final draft, :final topicConfig) =>
            _BasicInfoForm(draft: draft, topicConfig: topicConfig),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BasicInfoDelegate delegate,
    BasicInfoDraft draft,
  ) async {
    switch (delegate) {
      case BasicInfoOpenTransSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.eventTrans,
            selectedIds:
                draft.selectedTrans != null ? {draft.selectedTrans!.id} : {},
          ),
        );
        if (!mounted) return;
        if (result case TransSelectionResult(:final selected)) {
          context
              .read<BasicInfoBloc>()
              .add(BasicInfoTransSelected(selected));
        }

      case BasicInfoOpenMembersSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.eventMembers,
            selectedIds: draft.selectedMembers.map((m) => m.id).toSet(),
          ),
        );
        if (!mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context
              .read<BasicInfoBloc>()
              .add(BasicInfoMembersSelected(selected));
        }

      case BasicInfoOpenTagsSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.eventTags,
            selectedIds: draft.selectedTags.map((t) => t.id).toSet(),
          ),
        );
        if (!mounted) return;
        if (result case TagsSelectionResult(:final selected)) {
          context
              .read<BasicInfoBloc>()
              .add(BasicInfoTagsSelected(selected));
        }

      case BasicInfoOpenPayMemberSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.gasPayMember,
            selectedIds: draft.selectedPayMember != null
                ? {draft.selectedPayMember!.id}
                : {},
          ),
        );
        if (!mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context
              .read<BasicInfoBloc>()
              .add(BasicInfoPayMemberSelected(selected.firstOrNull));
        }
    }
  }
}

class _BasicInfoForm extends StatelessWidget {
  final BasicInfoDraft draft;
  final TopicConfig topicConfig;

  const _BasicInfoForm({required this.draft, required this.topicConfig});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _EventNameField(value: draft.eventName),
        const SizedBox(height: 16),
        _ReadOnlyRow(
          label: 'トピック',
          value: draft.selectedTopic?.topicName ?? '未設定',
        ),
        const SizedBox(height: 16),
        _SelectionRow(
          label: '交通手段',
          value: draft.selectedTrans?.transName ?? '未選択',
          onEditPressed: () => context
              .read<BasicInfoBloc>()
              .add(const BasicInfoEditTransPressed()),
        ),
        if (topicConfig.showKmPerGas) ...[
          const SizedBox(height: 16),
          _NumberInputField(
            label: '燃費 (km/L)',
            value: draft.kmPerGasInput,
            onChanged: (input) => context
                .read<BasicInfoBloc>()
                .add(BasicInfoKmPerGasChanged(input)),
          ),
        ],
        if (topicConfig.showPricePerGas) ...[
          const SizedBox(height: 16),
          _NumberInputField(
            label: 'ガソリン単価 (円/L)',
            value: draft.pricePerGasInput,
            onChanged: (input) => context
                .read<BasicInfoBloc>()
                .add(BasicInfoPricePerGasChanged(input)),
          ),
        ],
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
        if (topicConfig.showPayMember) ...[
          const SizedBox(height: 16),
          _SelectionRow(
            label: 'ガソリン支払者',
            value: draft.selectedPayMember?.memberName ?? '未選択',
            onEditPressed: () => context
                .read<BasicInfoBloc>()
                .add(const BasicInfoEditPayMemberPressed()),
          ),
        ],
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

/// 読み取り専用ラベル行（タップ・編集不可）
class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({
    required this.label,
    required this.value,
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
      ],
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
