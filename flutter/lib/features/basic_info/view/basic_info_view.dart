import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/master/tag/tag_domain.dart';
import '../../../domain/master/trans/trans_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../widgets/numeric_input_row.dart';
import '../bloc/basic_info_bloc.dart';
import '../bloc/basic_info_event.dart';
import '../bloc/basic_info_state.dart';
import '../draft/basic_info_draft.dart';

/// BasicInfo タブの表示・編集View。
class BasicInfoView extends StatelessWidget {
  const BasicInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BasicInfoBloc, BasicInfoState>(
      builder: (context, state) {
        return switch (state) {
          BasicInfoLoading() =>
            const Center(child: CircularProgressIndicator()),
          BasicInfoError(:final message) => Center(child: Text(message)),
          BasicInfoLoaded(
            :final draft,
            :final topicConfig,
            :final allTrans,
            :final allMembers,
            :final memberSuggestions,
            :final tagSuggestions,
            :final isSaving,
          ) =>
            draft.isEditing
                ? _BasicInfoForm(
                    draft: draft,
                    topicConfig: topicConfig,
                    allTrans: allTrans,
                    allMembers: allMembers,
                    memberSuggestions: memberSuggestions,
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
    return GestureDetector(
      key: const Key('basicInfoRead_container_section'),
      onTap: () => context.read<BasicInfoBloc>().add(const BasicInfoEditModeEntered()),
      child: Container(
        color: const Color(0xFFE8F4F8),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            const SizedBox(height: 12),
            Text(
              key: const Key('basicInfoRead_text_tapHint'),
              'タップして編集',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
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

// ── 編集フォーム ──────────────────────────────────────────────────────────

class _BasicInfoForm extends StatelessWidget {
  final BasicInfoDraft draft;
  final TopicConfig topicConfig;
  final List<TransDomain> allTrans;
  final List<MemberDomain> allMembers;
  final List<MemberDomain> memberSuggestions;
  final List<TagDomain> tagSuggestions;
  final bool isSaving;

  const _BasicInfoForm({
    required this.draft,
    required this.topicConfig,
    required this.allTrans,
    required this.allMembers,
    required this.memberSuggestions,
    required this.tagSuggestions,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _EventNameField(value: draft.eventName),
        const Divider(height: 1),
        _TransChipSection(
          allTrans: allTrans,
          selectedTrans: draft.selectedTrans,
        ),
        const Divider(height: 1),
        _MemberInputSection(
          selectedMembers: draft.selectedMembers,
          memberSuggestions: memberSuggestions,
          allMembers: allMembers,
        ),
        const Divider(height: 1),
        _TagInputSection(
          selectedTags: draft.selectedTags,
          tagSuggestions: tagSuggestions,
        ),
        if (topicConfig.showKmPerGas) ...[
          const Divider(height: 1),
          NumericInputRow(
            key: const Key('km_per_gas_input_row'),
            label: '燃費',
            unit: 'km/L',
            value: draft.kmPerGasInput,
            isDecimal: true,
            onChanged: (input) => context
                .read<BasicInfoBloc>()
                .add(BasicInfoKmPerGasChanged(input)),
          ),
        ],
        if (topicConfig.showPricePerGas) ...[
          const Divider(height: 1),
          NumericInputRow(
            label: 'ガソリン単価',
            unit: '円/L',
            value: draft.pricePerGasInput,
            onChanged: (input) => context
                .read<BasicInfoBloc>()
                .add(BasicInfoPricePerGasChanged(input)),
          ),
        ],
        if (topicConfig.showPayMember) ...[
          const Divider(height: 1),
          _GasPayMemberChipSection(
            selectedMembers: draft.selectedMembers,
            selectedPayMember: draft.selectedPayMember,
          ),
        ],
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('basicInfoForm_button_cancel'),
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
                  key: const Key('basicInfoForm_button_save'),
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

// ── イベント名入力 ────────────────────────────────────────────────────────

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

// ── 交通手段チップセクション ──────────────────────────────────────────────

/// 全交通手段マスタをチップで横並び表示する。単一選択。
class _TransChipSection extends StatelessWidget {
  final List<TransDomain> allTrans;
  final TransDomain? selectedTrans;

  const _TransChipSection({
    required this.allTrans,
    required this.selectedTrans,
  });

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
          Text('交通手段', style: labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: allTrans.map((trans) {
              final isSelected = selectedTrans?.id == trans.id;
              return FilterChip(
                key: Key('basicInfo_chip_trans_${trans.id}'),
                label: Text(trans.transName),
                selected: isSelected,
                onSelected: (_) => context
                    .read<BasicInfoBloc>()
                    .add(BasicInfoTransChipToggled(trans)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── メンバー入力セクション ────────────────────────────────────────────────

/// 選択済みメンバーチップ（×ボタン付き）と入力欄をWrapで横並び表示。
/// 入力欄フォーカスでドロップダウン（CompositedTransformFollower）を表示。
class _MemberInputSection extends StatefulWidget {
  final List<MemberDomain> selectedMembers;
  final List<MemberDomain> memberSuggestions;
  final List<MemberDomain> allMembers;

  const _MemberInputSection({
    required this.selectedMembers,
    required this.memberSuggestions,
    required this.allMembers,
  });

  @override
  State<_MemberInputSection> createState() => _MemberInputSectionState();
}

class _MemberInputSectionState extends State<_MemberInputSection> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _showOverlay(BuildContext context, List<MemberDomain> suggestions, String currentInput) {
    _removeOverlay();
    final hasAddNew = currentInput.trim().isNotEmpty &&
        !widget.selectedMembers.any(
          (m) => m.memberName.toLowerCase() == currentInput.trim().toLowerCase(),
        ) &&
        !suggestions.any(
          (m) => m.memberName.toLowerCase() == currentInput.trim().toLowerCase(),
        );
    if (suggestions.isEmpty && !hasAddNew) return;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: 260,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 36),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  ...suggestions.map(
                    (member) => ListTile(
                      key: Key('basicInfo_item_memberSuggestion_${member.id}'),
                      dense: true,
                      title: Text(member.memberName),
                      onTap: () {
                        context
                            .read<BasicInfoBloc>()
                            .add(BasicInfoMemberSuggestionSelected(member));
                        _controller.clear();
                        _removeOverlay();
                      },
                    ),
                  ),
                  if (hasAddNew)
                    ListTile(
                      key: const Key('basicInfo_item_memberAddNew'),
                      dense: true,
                      title: Text('"${currentInput.trim()}" を追加'),
                      leading: const Icon(Icons.add, size: 18),
                      onTap: () {
                        final input = _controller.text;
                        context
                            .read<BasicInfoBloc>()
                            .add(BasicInfoMemberInputConfirmed(input));
                        _controller.clear();
                        _removeOverlay();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _clearInput() {
    _controller.clear();
    context.read<BasicInfoBloc>().add(const BasicInfoMemberInputChanged(''));
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
          Text('メンバー', style: labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...widget.selectedMembers.map(
                (member) => Chip(
                  key: Key('basicInfo_chip_member_${member.id}'),
                  label: Text(member.memberName),
                  onDeleted: () => context
                      .read<BasicInfoBloc>()
                      .add(BasicInfoMemberRemoved(member)),
                ),
              ),
              CompositedTransformTarget(
                link: _layerLink,
                child: SizedBox(
                  width: 140,
                  child: TextField(
                    key: const Key('basicInfo_field_memberInput'),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'メンバーを追加',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    onTap: () {
                      context
                          .read<BasicInfoBloc>()
                          .add(const BasicInfoMemberInputChanged(''));
                      _showOverlay(
                        context,
                        widget.memberSuggestions,
                        _controller.text,
                      );
                    },
                    onChanged: (input) {
                      context
                          .read<BasicInfoBloc>()
                          .add(BasicInfoMemberInputChanged(input));
                      _showOverlay(
                        context,
                        widget.memberSuggestions,
                        input,
                      );
                    },
                    onSubmitted: (input) {
                      context
                          .read<BasicInfoBloc>()
                          .add(BasicInfoMemberInputConfirmed(input));
                      _clearInput();
                      _removeOverlay();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── タグ入力セクション ────────────────────────────────────────────────────

/// 選択済みタグチップ（×ボタン付き）と入力欄をWrapで横並び表示。
/// 入力欄フォーカスでドロップダウン（CompositedTransformFollower）を表示。
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _showOverlay(BuildContext context, List<TagDomain> suggestions, String currentInput) {
    _removeOverlay();
    final hasAddNew = currentInput.trim().isNotEmpty &&
        !widget.selectedTags.any(
          (t) => t.tagName.toLowerCase() == currentInput.trim().toLowerCase(),
        ) &&
        !suggestions.any(
          (t) => t.tagName.toLowerCase() == currentInput.trim().toLowerCase(),
        );
    if (suggestions.isEmpty && !hasAddNew) return;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: 260,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 36),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  ...suggestions.take(4).map(
                    (tag) => ListTile(
                      key: Key('basicInfo_item_tagSuggestion_${tag.id}'),
                      dense: true,
                      title: Text(tag.tagName),
                      onTap: () {
                        context
                            .read<BasicInfoBloc>()
                            .add(BasicInfoTagSuggestionSelected(tag));
                        _clearInput();
                        _removeOverlay();
                      },
                    ),
                  ),
                  if (hasAddNew)
                    ListTile(
                      key: const Key('basicInfo_item_tagAddNew'),
                      dense: true,
                      title: Text('"${currentInput.trim()}" を追加'),
                      leading: const Icon(Icons.add, size: 18),
                      onTap: () {
                        final input = _controller.text;
                        context
                            .read<BasicInfoBloc>()
                            .add(BasicInfoTagInputConfirmed(input));
                        _clearInput();
                        _removeOverlay();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...widget.selectedTags.map(
                (tag) => Chip(
                  key: Key('basicInfo_chip_tag_${tag.id}'),
                  label: Text(tag.tagName),
                  onDeleted: () => context
                      .read<BasicInfoBloc>()
                      .add(BasicInfoTagRemoved(tag)),
                ),
              ),
              CompositedTransformTarget(
                link: _layerLink,
                child: SizedBox(
                  width: 140,
                  child: TextField(
                    key: const Key('basicInfo_field_tagInput'),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '新しいタグを追加',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    onTap: () {
                      context
                          .read<BasicInfoBloc>()
                          .add(const BasicInfoTagInputChanged(''));
                      _showOverlay(
                        context,
                        widget.tagSuggestions,
                        _controller.text,
                      );
                    },
                    onChanged: (input) {
                      context
                          .read<BasicInfoBloc>()
                          .add(BasicInfoTagInputChanged(input));
                      _showOverlay(
                        context,
                        widget.tagSuggestions,
                        input,
                      );
                    },
                    onSubmitted: (input) {
                      context
                          .read<BasicInfoBloc>()
                          .add(BasicInfoTagInputConfirmed(input));
                      _clearInput();
                      _removeOverlay();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ガソリン支払者チップセクション ────────────────────────────────────────

/// イベントメンバー全員をチップで表示。単一選択（支払者を選ぶ）。
class _GasPayMemberChipSection extends StatelessWidget {
  final List<MemberDomain> selectedMembers;
  final MemberDomain? selectedPayMember;

  const _GasPayMemberChipSection({
    required this.selectedMembers,
    required this.selectedPayMember,
  });

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
          Text('ガソリン支払者', style: labelStyle),
          const SizedBox(height: 8),
          if (selectedMembers.isEmpty)
            Text(
              key: const Key('basicInfo_text_payMemberHint'),
              'メンバーを先に選択してください',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedMembers.map((member) {
                final isSelected = selectedPayMember?.id == member.id;
                return FilterChip(
                  key: Key('basicInfo_chip_payMember_${member.id}'),
                  label: Text(member.memberName),
                  selected: isSelected,
                  onSelected: (_) => context
                      .read<BasicInfoBloc>()
                      .add(BasicInfoPayMemberChipToggled(member)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
