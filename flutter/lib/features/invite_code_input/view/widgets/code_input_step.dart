import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/invite_code_input_bloc.dart';
import '../../bloc/invite_code_input_event.dart';
import '../../bloc/invite_code_input_state.dart';

class CodeInputStep extends StatefulWidget {
  final InviteCodeInputInitial state;

  const CodeInputStep({super.key, required this.state});

  @override
  State<CodeInputStep> createState() => _CodeInputStepState();
}

class _CodeInputStepState extends State<CodeInputStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.code);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void didUpdateWidget(CodeInputStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部からcodeが変わった場合のみ更新（フォーカス中の入力を壊さない）
    if (widget.state.code != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.state.code,
        selection: TextSelection.fromPosition(
          TextPosition(offset: widget.state.code.length),
        ),
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
    final isCodeEmpty = widget.state.code.isEmpty;
    final formatError = widget.state.formatError;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '招待コードを入力してください',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('invite_code_text_field'),
            controller: _controller,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'ABC-1234',
              border: const OutlineInputBorder(),
              errorText: formatError,
            ),
            onChanged: (value) {
              context
                  .read<InviteCodeInputBloc>()
                  .add(InviteCodeChanged(value));
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('invite_code_next_button'),
            onPressed: isCodeEmpty
                ? null
                : () => context
                    .read<InviteCodeInputBloc>()
                    .add(const InviteCodeSubmitted()),
            child: const Text('次へ'),
          ),
        ],
      ),
    );
  }
}
