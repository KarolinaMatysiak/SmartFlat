import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _livingSpaceService = LivingSpaceService();
  
  List<Map<String, dynamic>> _members = [];
  String? _selectedMemberId;
  bool _isSaving = false;
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final spaceProvider = context.read<LivingSpaceProvider>();
    final spaceDoc = spaceProvider.spacesSnapshot?.docs.first;
    
    if (spaceDoc != null) {
      final memberIds = List<String>.from(spaceDoc.data()['memberIds'] ?? []);
      try {
        final members = await _livingSpaceService.getMembers(memberIds);
        if (mounted) {
          setState(() {
            _members = members;
            _isLoadingMembers = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingMembers = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tytuł nie może być pusty")),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      await context.read<TaskProvider>().addTask(
        title, 
        desc, 
        assignedTo: _selectedMemberId,
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd podczas dodawania: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nowe Zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Opis (opcjonalnie)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoadingMembers)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                value: _selectedMemberId,
                decoration: const InputDecoration(
                  labelText: "Przypisz do",
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text("Nieprzypisane")),
                  ..._members.map((m) => DropdownMenuItem(
                    value: m['createdBy'],
                    child: Text(m['firstName'] ?? m['userName'] ?? 'Użytkownik'),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedMemberId = val),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Zapisz Zadanie", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
