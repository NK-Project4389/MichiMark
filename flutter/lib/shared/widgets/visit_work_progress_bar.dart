import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/action_time/action_state.dart';
import '../../domain/visit_work/visit_work_segment.dart';
import '../../domain/visit_work/visit_work_timeline.dart';

/// visitWork 向けプログレスバー（時間軸タイムライン）
///
/// ```
/// [09:00]─────────────────────────────[13:00]
///   ██移動██ ████████作業████████ ██休憩██ ████作業████
/// ```
class VisitWorkProgressBar extends StatelessWidget {
  final VisitWorkTimeline timeline;

  static final _timeFormat = DateFormat('HH:mm');

  const VisitWorkProgressBar({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final segments = timeline.segments;

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    final startTime = timeline.startTime;
    final endTime = timeline.isOngoing ? DateTime.now() : timeline.endTime;

    if (startTime == null || endTime == null) {
      return const SizedBox.shrink();
    }

    final totalDuration = endTime.difference(startTime);
    if (totalDuration.inSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final startLabel = _timeFormat.format(startTime);
    final endLabel = timeline.isOngoing ? '進行中' : _timeFormat.format(endTime);

    return Column(
      key: const Key('visit_work_progress_bar'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 時刻ラベル行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              startLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              endLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: timeline.isOngoing
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // プログレスバー
        SizedBox(
          height: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Row(
                children: segments.map((seg) {
                  final segDuration = seg.duration;
                  final ratio = segDuration.inMicroseconds /
                      totalDuration.inMicroseconds;
                  final width = (totalWidth * ratio).clamp(0.0, totalWidth);
                  return _SegmentBar(
                    segment: seg,
                    width: width,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final VisitWorkSegment segment;
  final double width;

  const _SegmentBar({
    required this.segment,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForState(segment.state);
    final label = _labelForState(segment.state);

    return SizedBox(
      width: width,
      child: Tooltip(
        message: label,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: Colors.white,
              width: 0.5,
            ),
          ),
          child: width > 30
              ? Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Color _colorForState(ActionState state) {
    return switch (state) {
      ActionState.moving => Colors.grey.shade400,
      ActionState.waiting => Colors.blue.shade300,
      ActionState.working => const Color(0xFF1E8A8A), // テーマカラー（Teal）
      ActionState.break_ => Colors.orange.shade300,
    };
  }

  String _labelForState(ActionState state) {
    return switch (state) {
      ActionState.moving => '移動',
      ActionState.waiting => '滞在',
      ActionState.working => '作業',
      ActionState.break_ => '休憩',
    };
  }
}
