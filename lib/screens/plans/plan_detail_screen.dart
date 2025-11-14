import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/firestore_provider.dart';
import '../../models/plan.dart';
import '../chat/chat_screen.dart';

class PlanDetailScreen extends ConsumerWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider(planId));
    final tasksAsync = ref.watch(planTasksProvider(planId));
    final expensesAsync = ref.watch(planExpensesProvider(planId));

    return planAsync.when(
      data: (plan) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(plan.title),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.info), text: '詳細'),
                  Tab(icon: Icon(Icons.checklist), text: 'タスク'),
                  Tab(icon: Icon(Icons.attach_money), text: '費用'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // 詳細タブ
                _PlanInfoTab(plan: plan),
                // タスクタブ
                tasksAsync.when(
                  data: (tasks) => _TasksTab(
                    planId: planId,
                    tasks: tasks,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('エラー: $error')),
                ),
                // 費用タブ
                expensesAsync.when(
                  data: (expenses) => _ExpensesTab(
                    planId: planId,
                    expenses: expenses,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('エラー: $error')),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(planId: planId),
                  ),
                );
              },
              child: const Icon(Icons.chat),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('エラー: $error')),
      ),
    );
  }
}

class _PlanInfoTab extends StatelessWidget {
  final Plan plan;

  const _PlanInfoTab({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (plan.description != null) ...[
          const Text(
            '説明',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(plan.description!),
          const SizedBox(height: 24),
        ],
        if (plan.startDate != null || plan.endDate != null) ...[
          const Text(
            '日程',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                plan.startDate != null
                    ? DateFormat('yyyy年MM月dd日').format(plan.startDate!)
                    : '未定',
              ),
              if (plan.endDate != null) ...[
                const Text(' 〜 '),
                Text(DateFormat('yyyy年MM月dd日').format(plan.endDate!)),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
        if (plan.location != null) ...[
          const Text(
            '場所',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place),
              const SizedBox(width: 8),
              Text(plan.location!),
            ],
          ),
          const SizedBox(height: 24),
        ],
        const Text(
          '参加者',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('${plan.participantIds.length}人参加中'),
        const SizedBox(height: 24),
        const Text(
          'ステータス',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(_getStatusText(plan.status)),
      ],
    );
  }

  String _getStatusText(PlanStatus status) {
    switch (status) {
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
}

class _TasksTab extends StatelessWidget {
  final String planId;
  final List tasks;

  const _TasksTab({required this.planId, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('タスクがありません'),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              // タスクの完了状態を更新
            },
          ),
          title: Text(task.title),
          subtitle: task.description != null ? Text(task.description!) : null,
        );
      },
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final String planId;
  final List expenses;

  const _ExpensesTab({required this.planId, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('費用の記録がありません'),
      );
    }

    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepPurple.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '合計',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '¥${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.title),
                subtitle: Text(
                  '${DateFormat('yyyy/MM/dd').format(expense.date)} - ${expense.splitBetween.length}人で割り勘',
                ),
                trailing: Text(
                  '¥${expense.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
