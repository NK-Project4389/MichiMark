import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/action_time_bloc.dart';
import '../bloc/action_time_event.dart';
import '../bloc/action_time_state.dart';
import '../projection/action_time_projection.dart';

/// ActionTime記録UI
class ActionTimeView extends StatelessWidget {
  const ActionTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActionTimeBloc, ActionTimeState>(
      listener: (context, state) {
        // ActionTimeNavigateBackDelegate はボトムシートを閉じない設計変更により処理しない
        // （定義は将来の他のユースケースのために残置）
        final error = state.errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                key: const Key('actionTime_sheet_header'),
                'アクション記録',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return _ActionTimeContent(state: state);
      },
    );
  }
}

class _ActionTimeContent extends StatelessWidget {
  final ActionTimeState state;

  const _ActionTimeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final projection = state.projection;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ヘッダー（ボトムシートが閉じていないことのテスト確認用）
        Text(
          key: const Key('actionTime_sheet_header'),
          'アクション記録',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // 現在状態表示
        _CurrentStateCard(label: projection.currentStateLabel),
        const SizedBox(height: 16),

        // アクションボタングリッド
        if (projection.buttonItems.isNotEmpty) ...[
          Text(
            '記録する',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _ActionButtonGrid(buttonItems: projection.buttonItems),
          const SizedBox(height: 16),
        ],

        // 休憩トグルボタン
        _BreakToggleButton(isBreakActive: projection.isBreakActive),
        const SizedBox(height: 16),

        // タイムラインログ
        Text(
          'ログ',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (projection.logItems.isEmpty)
          const Text('記録がありません')
        else
          ...projection.logItems.asMap().entries.map(
            (entry) => _LogItem(
              key: Key('actionTime_logItem_${entry.key}'),
              item: entry.value,
            ),
          ),
      ],
    );
  }
}

/// アクションボタングリッド。
/// 4件以下: Row + Expanded で等幅横並び
/// 5件以上: Wrap フォールバック
class _ActionButtonGrid extends StatelessWidget {
  final List<ActionButtonProjection> buttonItems;

  const _ActionButtonGrid({required this.buttonItems});

  @override
  Widget build(BuildContext context) {
    if (buttonItems.length <= 4) {
      return Row(
        children: buttonItems
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ActionButton(item: item),
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: buttonItems.map((item) => _ActionButton(item: item)).toList(),
      );
    }
  }
}

/// 各アクションボタン。
/// ビジュアル仕様: 高さ88px / 角丸14px / 通常白背景 / アクティブViolet背景
class _ActionButton extends StatelessWidget {
  final ActionButtonProjection item;

  const _ActionButton({required this.item});

  static const _activeBackground = Color(0xFFF5F3FF);
  static const _activeBorder = Color(0xFF7C3AED);
  static const _normalBackground = Color(0xFFFFFFFF);
  static const _normalBorder = Color(0xFFE9ECEF);
  static const _dividerColorActive = Color(0xFFC4B5FD);
  static const _dividerColorNormal = Color(0xFFE9ECEF);
  static const _titleColor = Color(0xFF1A1A2E);
  static const _timeColor = Color(0xFF7C3AED);
  static const _noRecordColor = Color(0xFFADB5BD);

  @override
  Widget build(BuildContext context) {
    final isActive = item.isLastPressed;
    final backgroundColor = isActive ? _activeBackground : _normalBackground;
    final borderColor = isActive ? _activeBorder : _normalBorder;
    final dividerColor = isActive ? _dividerColorActive : _dividerColorNormal;
    final lastTime = item.lastLoggedTimeLabel;

    return GestureDetector(
      onTap: () => context
          .read<ActionTimeBloc>()
          .add(ActionTimeLogRecorded(item.actionId)),
      child: Container(
        key: Key('actionTime_button_action_${item.actionId}'),
        height: 96,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.only(top: 12, left: 4, right: 4, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アクション名テキスト
            Text(
              item.actionName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),
            // 区切り線
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Container(height: 1, color: dividerColor),
            ),
            // 直近の押下時刻 or 未記録テキスト
            if (lastTime != null) ...[
              Text(
                key: Key('actionTime_label_lastTime_${item.actionId}'),
                lastTime,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _timeColor,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '直近の記録',
                style: TextStyle(
                  fontSize: 9,
                  color: _noRecordColor,
                ),
              ),
            ] else
              Text(
                key: Key('actionTime_label_noRecord_${item.actionId}'),
                '未記録',
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: _noRecordColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrentStateCard extends StatelessWidget {
  final String label;

  const _CurrentStateCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '現在の状態',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 16),
            Text(
              key: const Key('actionTime_label_currentState'),
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakToggleButton extends StatelessWidget {
  final bool isBreakActive;

  const _BreakToggleButton({required this.isBreakActive});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () =>
          context.read<ActionTimeBloc>().add(const ActionTimeBreakToggled()),
      icon: Icon(isBreakActive ? Icons.play_arrow : Icons.pause),
      label: Text(isBreakActive ? '休憩終了' : '休憩開始'),
    );
  }
}

class _LogItem extends StatelessWidget {
  final ActionTimeLogProjection item;

  const _LogItem({super.key, required this.item});

  void _showTimePickerBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      builder: (sheetContext) {
        return _TimePickerSheet(
          logId: item.id,
          bloc: context.read<ActionTimeBloc>(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: GestureDetector(
        key: Key('actionTime_timeLabel_${item.id}'),
        onTap: () => _showTimePickerBottomSheet(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.timestampLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (item.isAdjusted) ...[
              const SizedBox(width: 2),
              Icon(
                key: Key('actionTime_icon_adjusted_${item.id}'),
                Icons.edit,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
      title: Text(item.actionName),
      subtitle: Text(
        item.transitionLabel,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: () =>
            context.read<ActionTimeBloc>().add(ActionTimeLogDeleted(item.id)),
      ),
    );
  }
}

class _TimePickerSheet extends StatefulWidget {
  final String logId;
  final ActionTimeBloc bloc;

  const _TimePickerSheet({
    required this.logId,
    required this.bloc,
  });

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    // 初期値: 現在時刻
    _selectedTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('actionTime_timePicker_sheet'),
      height: 320,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                key: const Key('actionTime_timePicker_cancel'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                key: const Key('actionTime_timePicker_confirm'),
                onPressed: () {
                  widget.bloc.add(
                    ActionTimeLogAdjustedAtUpdated(
                      widget.logId,
                      _selectedTime,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('確定'),
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _selectedTime,
              onDateTimeChanged: (dt) {
                setState(() {
                  _selectedTime = dt;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
