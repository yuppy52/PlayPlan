import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/firestore_provider.dart';
import '../../models/plan.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(groupPlansProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('プラン'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // グループ設定画面へ
            },
          ),
        ],
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_note_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'まだプランがありません',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/create-plan',
                        arguments: groupId,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('プランを作成'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _PlanCard(plan: plan);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create-plan',
            arguments: groupId,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;

  const _PlanCard({required this.plan});

  Color _getStatusColor() {
    switch (plan.status) {
      case PlanStatus.planning:
        return Colors.orange;
      case PlanStatus.confirmed:
        return Colors.blue;
      case PlanStatus.ongoing:
        return Colors.green;
      case PlanStatus.completed:
        return Colors.grey;
      case PlanStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (plan.status) {
      case PlanStatus.planning:
        return '計画中';
      case PlanStatus.confirmed:
        return '確定';
      case PlanStatus.ongoing:
        return '実行中';
      case PlanStatus.completed:
        return '完了';
      case PlanStatus.cancelled:
        return 'キャンセル';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/plan-detail',
            arguments: plan.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (plan.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  plan.description!,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (plan.startDate != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MM/dd').format(plan.startDate!),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (plan.endDate != null) ...[
                      Text(' - ', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        DateFormat('MM/dd').format(plan.endDate!),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                    const SizedBox(width: 16),
                  ],
                  if (plan.location != null) ...[
                    Icon(Icons.place, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        plan.location!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.participantIds.length}人参加',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
