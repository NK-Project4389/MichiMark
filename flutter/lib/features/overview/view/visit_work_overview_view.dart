import 'package:flutter/material.dart';
import '../../../features/event_detail/projection/visit_work_projection.dart';
import '../../../shared/widgets/visit_work_progress_bar.dart';

/// visitWork 向けサブWidget
/// VisitWorkProjection をコンストラクタ経由で受け取る（BlocBuilderではない）
class VisitWorkOverviewView extends StatelessWidget {
  final VisitWorkProjection projection;

  const VisitWorkOverviewView({super.key, required this.projection});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // プログレスバー（時間軸タイムライン）
        if (projection.timeline.segments.isNotEmpty) ...[
          VisitWorkProgressBar(timeline: projection.timeline),
          const SizedBox(height: 24),
        ],
        // 時間の内訳セクション
        _SectionTitle(title: '時間の内訳'),
        _DurationRow(
          label: '移動',
          value: projection.movingLabel,
          color: Colors.grey.shade400,
        ),
        _DurationRow(
          label: '滞在',
          value: projection.stayingLabel,
          color: Colors.blue.shade300,
        ),
        _DurationRow(
          label: '作業',
          value: projection.workingLabel,
          color: const Color(0xFF1E8A8A),
        ),
        _DurationRow(
          label: '休憩',
          value: projection.breakLabel,
          color: Colors.orange.shade300,
        ),
        const Divider(),
        _InfoRow(label: '在現地', value: '${projection.onSiteLabel}（到着〜出発）'),
        const SizedBox(height: 16),
        // 売上セクション
        _SectionTitle(title: '売上'),
        _InfoRow(label: '売上合計', value: projection.revenueLabel),
        if (projection.revenuePerHourLabel != null)
          _InfoRow(label: '時給換算', value: projection.revenuePerHourLabel!),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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
      ),
    );
  }
}

class _DurationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DurationRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
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
      ),
    );
  }
}
