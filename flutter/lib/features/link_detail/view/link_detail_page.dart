import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/topic/topic_config.dart';
import '../../../features/fuel_detail/bloc/fuel_detail_bloc.dart';
import '../../../features/fuel_detail/bloc/fuel_detail_event.dart';
import '../../../features/fuel_detail/bloc/fuel_detail_state.dart';
import '../../../features/fuel_detail/view/fuel_detail_widget.dart';
import '../../../domain/master/member/member_domain.dart';
import '../../../features/selection/selection_args.dart';
import '../../../features/selection/selection_result.dart';
import '../bloc/link_detail_bloc.dart';
import '../bloc/link_detail_event.dart';
import '../bloc/link_detail_state.dart';
import '../draft/link_detail_draft.dart';

class LinkDetailPage extends StatefulWidget {
  const LinkDetailPage({super.key});

  @override
  State<LinkDetailPage> createState() => _LinkDetailPageState();
}

class _LinkDetailPageState extends State<LinkDetailPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LinkDetailBloc, LinkDetailState>(
      listener: (context, state) async {
        if (state is LinkDetailLoaded && state.delegate != null) {
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
          LinkDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          LinkDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          LinkDetailLoaded(:final draft, :final topicConfig, :final isSaving) =>
            _LinkDetailScaffold(draft: draft, topicConfig: topicConfig, isSaving: isSaving),
        };
      },
    );
  }

  Future<void> _handleDelegate(
    BuildContext context,
    LinkDetailDelegate delegate,
    LinkDetailDraft draft,
    List<MemberDomain> availableMembers,
  ) async {
    switch (delegate) {
      case LinkDetailDismissDelegate():
        if (!context.mounted) return;
        context.pop();

      case LinkDetailOpenMembersSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.linkMembers,
            selectedIds: draft.selectedMembers.map((m) => m.id).toSet(),
            candidateMembers: availableMembers.isNotEmpty ? availableMembers : null,
          ),
        );
        if (!context.mounted) return;
        if (result case MembersSelectionResult(:final selected)) {
          context
              .read<LinkDetailBloc>()
              .add(LinkDetailMembersSelected(selected));
        }

      case LinkDetailOpenActionsSelectionDelegate():
        final result = await context.push<SelectionResult>(
          '/selection',
          extra: SelectionArgs(
            type: SelectionType.linkActions,
            selectedIds: draft.selectedActions.map((a) => a.id).toSet(),
          ),
        );
        if (!context.mounted) return;
        if (result case ActionsSelectionResult(:final selected)) {
          context
              .read<LinkDetailBloc>()
              .add(LinkDetailActionsSelected(selected));
        }

      case LinkDetailSavedDelegate():
        if (!context.mounted) return;
        context.pop();

      case LinkDetailSaveErrorDelegate(:final message):
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }
}

class _LinkDetailScaffold extends StatelessWidget {
  final LinkDetailDraft draft;
  final TopicConfig topicConfig;
  final bool isSaving;

  const _LinkDetailScaffold({
    required this.draft,
    required this.topicConfig,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<LinkDetailBloc>()
              .add(const LinkDetailDismissPressed()),
        ),
        title: Text(
          draft.markLinkName.isEmpty ? '区間詳細' : draft.markLinkName,
        ),
        centerTitle: true,
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => context
                  .read<LinkDetailBloc>()
                  .add(const LinkDetailSaveTapped()),
              child: const Text('保存'),
            ),
        ],
      ),
      body: _LinkDetailForm(draft: draft, topicConfig: topicConfig),
    );
  }
}

class _LinkDetailForm extends StatelessWidget {
  final LinkDetailDraft draft;
  final TopicConfig topicConfig;

  const _LinkDetailForm({required this.draft, required this.topicConfig});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _NameField(value: draft.markLinkName),
        if (topicConfig.showLinkDistance) ...[
          const Divider(height: 1),
          _DistanceField(value: draft.distanceValueInput),
        ],
        const Divider(height: 1),
        _SelectionRow(
          label: 'メンバー',
          value: draft.selectedMembers.isEmpty
              ? '未選択'
              : draft.selectedMembers.map((m) => m.memberName).join('、'),
          onEditPressed: () => context
              .read<LinkDetailBloc>()
              .add(const LinkDetailEditMembersPressed()),
        ),
        const Divider(height: 1),
        _MemoField(value: draft.memo),
        if (topicConfig.showFuelDetail) ...[
          const Divider(height: 1),
          _FuelRow(
            isFuel: draft.isFuel,
            pricePerGasInput: draft.pricePerGasInput,
            gasQuantityInput: draft.gasQuantityInput,
            gasPriceInput: draft.gasPriceInput,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Field widgets ─────────────────────────────────────────────────────────

class _NameField extends StatefulWidget {
  final String value;
  const _NameField({required this.value});

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
                  context.read<LinkDetailBloc>().add(LinkDetailNameChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceField extends StatefulWidget {
  final String value;
  const _DistanceField({required this.value});

  @override
  State<_DistanceField> createState() => _DistanceFieldState();
}

class _DistanceFieldState extends State<_DistanceField> {
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
              '走行距離',
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
                hintText: '0',
                suffixText: 'km',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  context.read<LinkDetailBloc>().add(LinkDetailDistanceChanged(v)),
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
                  context.read<LinkDetailBloc>().add(LinkDetailMemoChanged(v)),
            ),
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

  const _FuelRow({
    required this.isFuel,
    required this.pricePerGasInput,
    required this.gasQuantityInput,
    required this.gasPriceInput,
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
          onChanged: (_) => context
              .read<LinkDetailBloc>()
              .add(const LinkDetailIsFuelToggled()),
        ),
        if (isFuel)
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
                  context.read<LinkDetailBloc>().add(
                        LinkDetailFuelFieldsChanged(
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
