import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../widgets/numeric_input_row.dart';
import '../../../features/fuel_detail/bloc/fuel_detail_bloc.dart';
import '../../../features/fuel_detail/bloc/fuel_detail_event.dart';
import '../../../features/fuel_detail/bloc/fuel_detail_state.dart';
import '../../../features/fuel_detail/view/fuel_detail_widget.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/mark_detail_bloc.dart';
import '../bloc/mark_detail_event.dart';
import '../bloc/mark_detail_state.dart';
import '../draft/mark_detail_draft.dart';

class MarkDetailPage extends StatefulWidget {
  const MarkDetailPage({super.key});

  @override
  State<MarkDetailPage> createState() => _MarkDetailPageState();
}

class _MarkDetailPageState extends State<MarkDetailPage> {
  static final _dateFormat = DateFormat('yyyy/MM/dd');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarkDetailBloc, MarkDetailState>(
      listener: (context, state) async {
        if (state is MarkDetailLoaded && state.delegate != null) {
          await _handleDelegate(
            context,
            state.delegate!,
            state.draft,
            state.availableMembers,
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          MarkDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          MarkDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          MarkDetailLoaded(
            :final draft,
            :final topicConfig,
            :final isSaving,
            :final availableMembers,
            :final showCancelConfirmDialog,
          ) =>
            Stack(
              children: [
                _MarkDetailScaffold(
                  draft: draft,
                  topicConfig: topicConfig,
                  dateFormat: _dateFormat,
                  isSaving: isSaving,
                  availableMembers: availableMembers,
                ),
                if (showCancelConfirmDialog)
                  _MarkDetailCancelConfirmDialog(),
              ],
            ),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BuildContext context,
    MarkDetailDelegate delegate,
    MarkDetailDraft draft,
    List<MemberDomain> availableMembers,
  ) async {
    switch (delegate) {
      case MarkDetailDismissDelegate():
        if (!context.mounted) return;
        context.pop();

      case MarkDetailOpenActionsSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.markActions,
            selectedIds: draft.selectedActions.map((a) => a.id).toSet(),
          ),
        );
        if (!context.mounted) return;
        if (result case ActionsSelectionResult(:final selected)) {
          context.read<MarkDetailBloc>().add(MarkDetailActionsSelected(selected));
        }

      case MarkDetailSavedDelegate():
        if (!context.mounted) return;
        context.pop();

      case MarkDetailSaveErrorDelegate(:final message):
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }
}

class _MarkDetailScaffold extends StatelessWidget {
  final MarkDetailDraft draft;
  final TopicConfig topicConfig;
  final DateFormat dateFormat;
  final bool isSaving;
  final List<MemberDomain> availableMembers;

  const _MarkDetailScaffold({
    required this.draft,
    required this.topicConfig,
    required this.dateFormat,
    required this.isSaving,
    required this.availableMembers,
  });

  @override
  Widget build(BuildContext context) {
    final title = draft.markLinkName.isEmpty
        ? '地点詳細'
        : '地点詳細：${draft.markLinkName}';
    return Scaffold(
      key: const Key('markDetail_screen'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title,
          key: const Key('markDetail_appBar_title'),
        ),
        centerTitle: true,
      ),
      body: _MarkDetailForm(
        draft: draft,
        topicConfig: topicConfig,
        dateFormat: dateFormat,
        availableMembers: availableMembers,
        isSaving: isSaving,
      ),
    );
  }
}

class _MarkDetailForm extends StatelessWidget {
  final MarkDetailDraft draft;
  final TopicConfig topicConfig;
  final DateFormat dateFormat;
  final List<MemberDomain> availableMembers;
  final bool isSaving;

  const _MarkDetailForm({
    required this.draft,
    required this.topicConfig,
    required this.dateFormat,
    required this.availableMembers,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (topicConfig.showNameField) ...[
          _NameField(
            key: const Key('markDetail_field_name'),
            value: draft.markLinkName,
          ),
          const Divider(height: 1),
        ],
        _DateRow(date: draft.markLinkDate, dateFormat: dateFormat),
        const Divider(height: 1),
        _MemberChipSection(
          availableMembers: availableMembers,
          selectedMembers: draft.selectedMembers,
        ),
        if (topicConfig.showMeterValue) ...[
          const Divider(height: 1),
          NumericInputRow(
            label: '累積メーター',
            unit: 'km',
            value: draft.meterValueInput,
            onChanged: (v) =>
                context.read<MarkDetailBloc>().add(MarkDetailMeterValueChanged(v)),
          ),
        ],
        const Divider(height: 1),
        _MemoField(value: draft.memo),
        if (topicConfig.showFuelDetail) ...[
          const Divider(height: 1),
          _FuelRow(
            isFuel: draft.isFuel,
            pricePerGasInput: draft.pricePerGasInput,
            gasQuantityInput: draft.gasQuantityInput,
            gasPriceInput: draft.gasPriceInput,
            availableMembers: availableMembers,
            selectedGasPayer: draft.selectedGasPayer,
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                key: const Key('markDetail_button_cancel'),
                onPressed: () => context
                    .read<MarkDetailBloc>()
                    .add(const MarkDetailDismissPressed()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                key: const Key('markDetail_button_save'),
                onPressed: isSaving
                    ? null
                    : () => context
                        .read<MarkDetailBloc>()
                        .add(const MarkDetailSaveTapped()),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────

class _NameField extends StatefulWidget {
  final String value;
  const _NameField({super.key, required this.value});

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
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
              '名称',
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
              onChanged: (v) =>
                  context.read<MarkDetailBloc>().add(MarkDetailNameChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}


class _MemoField extends StatefulWidget {
  final String value;
  const _MemoField({required this.value});

  @override
  State<_MemoField> createState() => _MemoFieldState();
}

class _MemoFieldState extends State<_MemoField> {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'メモ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
              maxLines: null,
              onChanged: (v) =>
                  context.read<MarkDetailBloc>().add(MarkDetailMemoChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime date;
  final DateFormat dateFormat;

  const _DateRow({required this.date, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '日付',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _pickDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  dateFormat.format(date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!context.mounted) return;
    if (picked != null) {
      context.read<MarkDetailBloc>().add(MarkDetailDateChanged(picked));
    }
  }
}

// ── メンバーチップセクション（インライン選択・multiple） ────────────────────

class _MemberChipSection extends StatelessWidget {
  final List<MemberDomain> availableMembers;
  final List<MemberDomain> selectedMembers;

  const _MemberChipSection({
    required this.availableMembers,
    required this.selectedMembers,
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
          Row(
            children: [
              Text('メンバー', style: labelStyle),
              const Spacer(),
              TextButton(
                key: const Key('markDetail_button_selectAllMembers'),
                onPressed: () => context
                    .read<MarkDetailBloc>()
                    .add(const MarkDetailMembersAllSelected()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('全選択'),
              ),
              TextButton(
                key: const Key('markDetail_button_clearAllMembers'),
                onPressed: () => context
                    .read<MarkDetailBloc>()
                    .add(const MarkDetailMembersAllCleared()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('全解除'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: availableMembers.map((member) {
              final isSelected = selectedMembers.any((m) => m.id == member.id);
              return FilterChip(
                key: Key('markDetail_chip_member_${member.id}'),
                label: Text(member.memberName),
                selected: isSelected,
                onSelected: (_) => context
                    .read<MarkDetailBloc>()
                    .add(MarkDetailMemberChipToggled(member)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── ガソリン支払者チップセクション（インライン選択・single） ──────────────────

class _GasPayerChipSection extends StatelessWidget {
  final List<MemberDomain> availableMembers;
  final MemberDomain? selectedGasPayer;

  const _GasPayerChipSection({
    required this.availableMembers,
    this.selectedGasPayer,
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
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: availableMembers.map((member) {
              final isSelected = selectedGasPayer?.id == member.id;
              return FilterChip(
                key: Key('markDetail_chip_gasPayer_${member.id}'),
                label: Text(member.memberName),
                selected: isSelected,
                onSelected: (_) => context
                    .read<MarkDetailBloc>()
                    .add(MarkDetailGasPayerChipToggled(member)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FuelRow extends StatelessWidget {
  final bool isFuel;
  final String pricePerGasInput;
  final String gasQuantityInput;
  final String gasPriceInput;
  final List<MemberDomain> availableMembers;
  final MemberDomain? selectedGasPayer;

  const _FuelRow({
    required this.isFuel,
    required this.pricePerGasInput,
    required this.gasQuantityInput,
    required this.gasPriceInput,
    required this.availableMembers,
    this.selectedGasPayer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('給油'),
          value: isFuel,
          onChanged: (_) =>
              context.read<MarkDetailBloc>().add(const MarkDetailIsFuelToggled()),
        ),
        if (isFuel) ...[
          BlocProvider(
            create: (_) => FuelDetailBloc()
              ..add(FuelDetailStarted(
                pricePerGas: pricePerGasInput,
                gasQuantity: gasQuantityInput,
                gasPrice: gasPriceInput,
              )),
            child: BlocListener<FuelDetailBloc, FuelDetailState>(
              listener: (context, state) {
                if (state.delegate case FuelDetailDraftChanged(:final draft)) {
                  context.read<MarkDetailBloc>().add(
                        MarkDetailFuelFieldsChanged(
                          pricePerGas: draft.pricePerGas,
                          gasQuantity: draft.gasQuantity,
                          gasPrice: draft.gasPrice,
                        ),
                      );
                }
              },
              child: const FuelDetailWidget(),
            ),
          ),
          const Divider(height: 1),
          _GasPayerChipSection(
            availableMembers: availableMembers,
            selectedGasPayer: selectedGasPayer,
          ),
        ],
      ],
    );
  }
}

// ── キャンセル確認ダイアログ ───────────────────────────────────────────────

class _MarkDetailCancelConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      key: const Key('markDetail_dialog_cancelConfirm'),
      title: const Text('変更を破棄しますか？'),
      content: const Text('保存されていない変更は失われます。'),
      actions: [
        CupertinoDialogAction(
          key: const Key('markDetail_button_discardConfirm'),
          isDestructiveAction: true,
          onPressed: () => context
              .read<MarkDetailBloc>()
              .add(const MarkDetailCancelDiscardConfirmed()),
          child: const Text('破棄する'),
        ),
        CupertinoDialogAction(
          key: const Key('markDetail_button_continueEdit'),
          onPressed: () => context
              .read<MarkDetailBloc>()
              .add(const MarkDetailCancelDialogDismissed()),
          child: const Text('編集を続ける'),
        ),
      ],
    );
  }
}
