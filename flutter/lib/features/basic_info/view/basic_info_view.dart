import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/basic_info_bloc.dart';
import '../bloc/basic_info_event.dart';
import '../bloc/basic_info_state.dart';
import '../draft/basic_info_draft.dart';

/// BasicInfo タブの表示・編集View。
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
        if (state is BasicInfoLoaded) {
          if (state.delegate != null) {
            await _handleDelegate(state.delegate!, state.draft);
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          BasicInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          BasicInfoError(:final message) => Center(child: Text(message)),
          BasicInfoLoaded(:final draft, :final topicConfig, :final tagSuggestions, :final isSaving) =>
            draft.isEditing
                ? _BasicInfoForm(
                    draft: draft,
                    topicConfig: topicConfig,
                    tagSuggestions: tagSuggestions,
                    isSaving: isSaving,
                  )
                : _BasicInfoReadView(
                    draft: draft,
                    topicConfig: topicConfig,
                  ),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BasicInfoDelegate delegate,
    BasicInfoDraft draft,
  ) async {
    // delegateを消費してnullにリセット（再タップを有効にする）
    if (!mounted) return;
    context.read<BasicInfoBloc>().add(const BasicInfoDelegateConsumed());

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
            candidateMembers: draft.selectedMembers.isEmpty
                ? null
                : draft.selectedMembers,
          ),
        );
        if (!mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context
              .read<BasicInfoBloc>()
              .add(BasicInfoPayMemberSelected(selected.firstOrNull));
        }

      case BasicInfoSavedDelegate():
        // 保存完了: 特に画面遷移なし（isEditingがfalseになっているので参照モードに戻る）
        break;

      case BasicInfoSavedAndDismissDelegate():
        // 「保存して戻る」: EventDetailPageのBlocListenerで画面を閉じる
        break;
    }
  }
}

// ── 参照モード ────────────────────────────────────────────────────────────

class _BasicInfoReadView extends StatelessWidget {
  final BasicInfoDraft draft;
  final TopicConfig topicConfig;

  const _BasicInfoReadView({
    required this.draft,
    required this.topicConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          children: [
            _ReadRow(label: 'イベント名', value: draft.eventName.isEmpty ? '未設定' : draft.eventName),
            const SizedBox(height: 12),
            _ReadRow(
              label: '交通手段',
              value: draft.selectedTrans?.transName ?? '未選択',
            ),
            const SizedBox(height: 12),
            _ReadRow(
              label: 'メンバー',
              value: draft.selectedMembers.isEmpty
                  ? '未選択'
                  : draft.selectedMembers.map((m) => m.memberName).join('、'),
            ),
            const SizedBox(height: 12),
            _ReadRow(
              label: 'タグ',
              value: draft.selectedTags.isEmpty
                  ? '未設定'
                  : draft.selectedTags.map((t) => t.tagName).join('、'),
            ),
            if (topicConfig.showKmPerGas) ...[
              const SizedBox(height: 12),
              _ReadRow(
                label: '燃費',
                value: draft.kmPerGasInput.isEmpty ? '未設定' : '${draft.kmPerGasInput} km/L',
              ),
            ],
            if (topicConfig.showPricePerGas) ...[
              const SizedBox(height: 12),
              _ReadRow(
                label: 'ガソリン単価',
                value: draft.pricePerGasInput.isEmpty ? '未設定' : '${draft.pricePerGasInput} 円/L',
              ),
            ],
            if (topicConfig.showPayMember) ...[
              const SizedBox(height: 12),
              _ReadRow(
                label: 'ガソリン支払者',
                value: draft.selectedPayMember?.memberName ?? '未選択',
              ),
            ],
          ],
        ),
        Positioned(
          right: 8,
          top: 4,
          child: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '編集',
            onPressed: () => context.read<BasicInfoBloc>().add(const BasicInfoEditModeEntered()),
          ),
        ),
      ],
    );
  }
}

class _ReadRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

class _BasicInfoForm extends StatelessWidget {
  final BasicInfoDraft draft;
  final TopicConfig topicConfig;
  final List<TagDomain> tagSuggestions;
  final bool isSaving;

  const _BasicInfoForm({
    required this.draft,
    required this.topicConfig,
    required this.tagSuggestions,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    // eventIdをBlocのstateから取得するのが難しいため、
    // BasicInfoSavePressedのeventIdは空文字を渡し、Blocが_eventIdを使用する
    // ただしSpecにはeventIdを渡す設計なので、ここではBasicInfoBlocのstateから参照する
    // BasicInfoBlocは_onStartedでeventIdを受け取っているため、BasicInfoSavePressedのeventIdは
    // BasicInfoBloc内で_eventIdとして保持する必要がある
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            _EventNameField(value: draft.eventName),
            const Divider(height: 1),
            _SelectionRow(
              label: '交通手段',
              value: draft.selectedTrans?.transName ?? '未選択',
              onEditPressed: () => context
                  .read<BasicInfoBloc>()
                  .add(const BasicInfoEditTransPressed()),
            ),
            const Divider(height: 1),
            _SelectionRow(
              label: 'メンバー',
              value: draft.selectedMembers.isEmpty
                  ? '未選択'
                  : draft.selectedMembers.map((m) => m.memberName).join('、'),
              onEditPressed: () => context
                  .read<BasicInfoBloc>()
                  .add(const BasicInfoEditMembersPressed()),
            ),
            const Divider(height: 1),
            _TagInputSection(
              selectedTags: draft.selectedTags,
              tagSuggestions: tagSuggestions,
            ),
            if (topicConfig.showKmPerGas) ...[
              const Divider(height: 1),
              _NumberInputField(
                label: '燃費',
                suffix: 'km/L',
                value: draft.kmPerGasInput,
                onChanged: (input) => context
                    .read<BasicInfoBloc>()
                    .add(BasicInfoKmPerGasChanged(input)),
              ),
            ],
            if (topicConfig.showPricePerGas) ...[
              const Divider(height: 1),
              _NumberInputField(
                label: 'ガソリン単価',
                suffix: '円/L',
                value: draft.pricePerGasInput,
                onChanged: (input) => context
                    .read<BasicInfoBloc>()
                    .add(BasicInfoPricePerGasChanged(input)),
              ),
            ],
            if (topicConfig.showPayMember) ...[
              const Divider(height: 1),
              _SelectionRow(
                label: 'ガソリン支払者',
                value: draft.selectedPayMember?.memberName ?? '未選択',
                onEditPressed: () => context
                    .read<BasicInfoBloc>()
                    .add(const BasicInfoEditPayMemberPressed()),
              ),
            ],
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => context
                        .read<BasicInfoBloc>()
                        .add(const BasicInfoEditCancelled()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 8),
              if (isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ElevatedButton(
                  onPressed: () => context
                      .read<BasicInfoBloc>()
                      .add(const BasicInfoSavePressed()),
                  child: const Text('保存'),
                ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'イベント名',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: '任意',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => context
                  .read<BasicInfoBloc>()
                  .add(BasicInfoEventNameChanged(value)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberInputField extends StatefulWidget {
  final String label;
  final String suffix;
  final String value;
  final ValueChanged<String> onChanged;

  const _NumberInputField({
    required this.label,
    required this.suffix,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: '0',
                suffixText: widget.suffix,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// タグのインライン入力・サジェスト・チップ表示セクション
class _TagInputSection extends StatefulWidget {
  final List<TagDomain> selectedTags;
  final List<TagDomain> tagSuggestions;

  const _TagInputSection({
    required this.selectedTags,
    required this.tagSuggestions,
  });

  @override
  State<_TagInputSection> createState() => _TagInputSectionState();
}

class _TagInputSectionState extends State<_TagInputSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearInput() {
    _controller.clear();
    context.read<BasicInfoBloc>().add(const BasicInfoTagInputChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('タグ', style: labelStyle),
          if (widget.selectedTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.selectedTags
                  .map((tag) => Chip(
                        label: Text(tag.tagName),
                        onDeleted: () => context
                            .read<BasicInfoBloc>()
                            .add(BasicInfoTagRemoved(tag)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '新しいタグを追加',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: (input) => context
                .read<BasicInfoBloc>()
                .add(BasicInfoTagInputChanged(input)),
            onSubmitted: (input) {
              context.read<BasicInfoBloc>().add(BasicInfoTagInputConfirmed(input));
              _clearInput();
            },
          ),
          if (widget.tagSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '最近使用したタグ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.tagSuggestions
                  .map((tag) => ActionChip(
                        label: Text(tag.tagName),
                        onPressed: () {
                          context
                              .read<BasicInfoBloc>()
                              .add(BasicInfoTagSuggestionSelected(tag));
                          _clearInput();
                        },
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
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
    return InkWell(
      onTap: onEditPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
