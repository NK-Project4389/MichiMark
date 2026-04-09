import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/numeric_input_row.dart';
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
            NumericInputRow(
              label: 'ガソリン単価',
              unit: '円/L',
              value: state.draft.pricePerGas,
              onChanged: (value) => context
                  .read<FuelDetailBloc>()
                  .add(FuelDetailPricePerGasChanged(value)),
            ),
            const Divider(height: 1),
            NumericInputRow(
              label: '給油量',
              unit: 'L',
              value: state.draft.gasQuantity,
              isDecimal: true,
              onChanged: (value) => context
                  .read<FuelDetailBloc>()
                  .add(FuelDetailGasQuantityChanged(value)),
            ),
            const Divider(height: 1),
            NumericInputRow(
              label: 'ガソリン代',
              unit: '円',
              value: state.draft.gasPrice,
              onChanged: (value) => context
                  .read<FuelDetailBloc>()
                  .add(FuelDetailGasPriceChanged(value)),
            ),
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
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
            ),
          ],
        );
      },
    );
  }
}
