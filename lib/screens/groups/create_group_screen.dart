import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/firestore_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/group.dart';
import '../../core/constants/app_constants.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final group = Group(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        memberIds: [currentUser.id],
        createdBy: currentUser.id,
        createdAt: now,
        updatedAt: now,
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.createGroup(group);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('グループの作成に失敗しました: $e')),
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
        title: const Text('グループを作成'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'グループ名',
                hintText: '例: 旅行仲間',
                prefixIcon: Icon(Icons.groups),
              ),
              maxLength: AppConstants.maxGroupNameLength,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'グループ名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                hintText: 'グループの説明を入力',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateGroup,
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
