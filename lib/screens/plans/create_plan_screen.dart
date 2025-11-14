import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/firestore_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/plan.dart';
import '../../core/constants/app_constants.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  final String groupId;

  const CreatePlanScreen({super.key, required this.groupId});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleCreatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final plan = Plan(
        id: const Uuid().v4(),
        groupId: widget.groupId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        participantIds: [currentUser.id],
        createdBy: currentUser.id,
        createdAt: now,
        updatedAt: now,
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.createPlan(plan);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プランの作成に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プランを作成'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                hintText: '例: 京都旅行',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: AppConstants.maxPlanTitleLength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                hintText: 'プランの説明を入力',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '場所（任意）',
                hintText: '例: 京都',
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '日程（任意）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _startDate == null
                          ? '開始日'
                          : DateFormat('yyyy/MM/dd').format(_startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('〜'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _endDate == null
                          ? '終了日'
                          : DateFormat('yyyy/MM/dd').format(_endDate!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreatePlan,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('作成'),
            ),
          ],
        ),
      ),
    );
  }
}
