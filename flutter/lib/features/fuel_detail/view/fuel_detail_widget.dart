import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/fuel_detail_bloc.dart';
import '../bloc/fuel_detail_event.dart';
import '../bloc/fuel_detail_state.dart';

/// FuelDetailWidget
///
/// MarkDetail / LinkDetail 画面にインラインで埋め込む給油計算ウィジェット。
/// 親FeatureがBlocProviderでFuelDetailBlocを提供すること。
/// 親Widget側でBlocListenerを使いFuelDetailDraftChangedを検知すること。
class FuelDetailWidget extends StatelessWidget {
  const FuelDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FuelDetailBloc, FuelDetailState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FuelTextField(
              label: 'ガソリン単価（円/L）',
              value: state.draft.pricePerGas,
              keyboardType: TextInputType.number,
              onChanged: (value) => context
                  .read<FuelDetailBloc>()
                  .add(FuelDetailPricePerGasChanged(value)),
            ),
            const SizedBox(height: 8),
            _FuelTextField(
              label: '給油量（L）',
              value: state.draft.gasQuantity,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => context
                  .read<FuelDetailBloc>()
                  .add(FuelDetailGasQuantityChanged(value)),
            ),
            const SizedBox(height: 8),
            _FuelTextField(
              label: 'ガソリン代（円）',
              value: state.draft.gasPrice,
              keyboardType: TextInputType.number,
              onChanged: (value) => context
                  .read<FuelDetailBloc>()
                  .add(FuelDetailGasPriceChanged(value)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<FuelDetailBloc>()
                        .add(const FuelDetailClearTapped()),
                    child: const Text('クリア'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<FuelDetailBloc>()
                        .add(const FuelDetailCalculateTapped()),
                    child: const Text('計算'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FuelTextField extends StatefulWidget {
  final String label;
  final String value;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _FuelTextField({
    required this.label,
    required this.value,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  State<_FuelTextField> createState() => _FuelTextFieldState();
}

class _FuelTextFieldState extends State<_FuelTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_FuelTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 計算・クリアでBlocが値を更新したときのみコントローラを同期する
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
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
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
}
