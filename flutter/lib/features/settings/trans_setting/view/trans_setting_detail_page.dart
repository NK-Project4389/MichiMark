import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/trans_setting_detail_bloc.dart';
import '../bloc/trans_setting_detail_event.dart';
import '../bloc/trans_setting_detail_state.dart';
import '../draft/trans_setting_detail_draft.dart';

class TransSettingDetailPage extends StatelessWidget {
  const TransSettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransSettingDetailBloc, TransSettingDetailState>(
      listener: (context, state) {
        if (state is TransSettingDetailLoaded && state.delegate != null) {
          switch (state.delegate!) {
            case TransSettingDetailDidSaveDelegate():
              if (context.canPop()) { context.pop(true); } else { context.go('/'); }
            case TransSettingDetailDismissDelegate():
              if (context.canPop()) { context.pop(); } else { context.go('/'); }
          }
        }
      },
      builder: (context, state) {
        return switch (state) {
          TransSettingDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          TransSettingDetailError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          TransSettingDetailLoaded() => _TransSettingDetailScaffold(
              state: state,
            ),
        };
      },
    );
  }
}

class _TransSettingDetailScaffold extends StatelessWidget {
  final TransSettingDetailLoaded state;

  const _TransSettingDetailScaffold({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('transSettingDetail_appBar_backButton'),
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context
              .read<TransSettingDetailBloc>()
              .add(const TransSettingDetailBackTapped()),
        ),
        title: Text(
          state.draft.transName.isEmpty ? '交通手段' : state.draft.transName,
        ),
        centerTitle: true,
      ),
      body: _TransSettingDetailForm(draft: state.draft, state: state),
    );
  }
}

class _TransSettingDetailForm extends StatelessWidget {
  final TransSettingDetailDraft draft;
  final TransSettingDetailLoaded state;

  const _TransSettingDetailForm({required this.draft, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _TransNameField(value: draft.transName),
        if (state.nameError != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ErrorText(state.nameError!),
          ),
        ],
        const Divider(height: 1),
        _KmPerGasField(value: draft.displayKmPerGas),
        if (state.kmPerGasError != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ErrorText(state.kmPerGasError!),
          ),
        ],
        const Divider(height: 1),
        _MeterValueField(value: draft.displayMeterValue),
        if (state.meterValueError != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ErrorText(state.meterValueError!),
          ),
        ],
        const Divider(height: 1),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('表示'),
          value: draft.isVisible,
          onChanged: (v) => context
              .read<TransSettingDetailBloc>()
              .add(TransSettingDetailIsVisibleChanged(v)),
        ),
        if (state.saveErrorMessage != null) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _ErrorText(state.saveErrorMessage!),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                key: const Key('transSettingDetail_button_cancel'),
                onPressed: () => context
                    .read<TransSettingDetailBloc>()
                    .add(const TransSettingDetailBackTapped()),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                key: const Key('transSettingDetail_button_save'),
                onPressed: state.isSaving
                    ? null
                    : () => context
                        .read<TransSettingDetailBloc>()
                        .add(const TransSettingDetailSaveTapped()),
                child: state.isSaving
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

// ── Field widgets ──────────────────────────────────────────────────────────

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 12,
      ),
    );
  }
}

class _TransNameField extends StatefulWidget {
  final String value;
  const _TransNameField({required this.value});

  @override
  State<_TransNameField> createState() => _TransNameFieldState();
}

class _TransNameFieldState extends State<_TransNameField> {
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
              '交通手段名',
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
                hintText: '必須',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              autofocus: true,
              onChanged: (v) => context
                  .read<TransSettingDetailBloc>()
                  .add(TransSettingDetailNameChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KmPerGasField extends StatefulWidget {
  final String value;
  const _KmPerGasField({required this.value});

  @override
  State<_KmPerGasField> createState() => _KmPerGasFieldState();
}

class _KmPerGasFieldState extends State<_KmPerGasField> {
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
              '燃費 (km/L)',
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
                hintText: '例: 15.5',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => context
                  .read<TransSettingDetailBloc>()
                  .add(TransSettingDetailKmPerGasChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeterValueField extends StatefulWidget {
  final String value;
  const _MeterValueField({required this.value});

  @override
  State<_MeterValueField> createState() => _MeterValueFieldState();
}

class _MeterValueFieldState extends State<_MeterValueField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _MeterValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // カンマ整形後の値をコントローラーに反映（カーソル位置は末尾に）
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
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
              'メーター (km)',
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
                hintText: '例: 10,000',
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => context
                  .read<TransSettingDetailBloc>()
                  .add(TransSettingDetailMeterValueChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}
