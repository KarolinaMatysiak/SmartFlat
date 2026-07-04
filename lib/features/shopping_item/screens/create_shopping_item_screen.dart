import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_flat/core/widgets/app_background.dart';
import 'package:smart_flat/core/widgets/form_input.dart';
import 'package:smart_flat/core/widgets/form_submit_button.dart';
import 'package:smart_flat/features/living_space/providers/living_space_provider.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';
import 'package:smart_flat/features/shopping_item/providers/shopping_item_provider.dart';

class CreateShoppingItemScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? shoppingItemToEdit;

  const CreateShoppingItemScreen({super.key, this.shoppingItemToEdit});

  @override
  State<CreateShoppingItemScreen> createState() => _CreateShoppingItemScreenState();
}

class _CreateShoppingItemScreenState extends State<CreateShoppingItemScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final _livingSpaceService = LivingSpaceService();
  
  List<Map<String, dynamic>> _members = [];
  String? _selectedMemberId;
  bool _isSaving = false;
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.shoppingItemToEdit?.data()['title']);
    _descController = TextEditingController(text: widget.shoppingItemToEdit?.data()['description']);
    _selectedMemberId = widget.shoppingItemToEdit?.data()['assignedTo'];
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

  Future<void> _saveShoppingItem() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title cannot be empty")),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      if (widget.shoppingItemToEdit != null) {
        await context.read<ShoppingItemProvider>().updateShoppingItem(
          widget.shoppingItemToEdit!.id,
          title: title,
          description: desc,
          assignedTo: _selectedMemberId,
        );
      } else {
        await context.read<ShoppingItemProvider>().addShoppingItem(
          title, 
          desc, 
          assignedTo: _selectedMemberId,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shoppingItemToEdit != null ? "Edit Item" : "New Item", 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormInput(
                      controller: _titleController,
                      icon: Icons.shopping_bag_outlined,
                      label: "Title",
                    ),
                    const SizedBox(height: 16),
                    FormInput(
                      controller: _descController,
                      icon: Icons.description_outlined,
                      label: "Description",
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingMembers)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedMemberId,
                        decoration: InputDecoration(
                          labelText: "Assign to",
                          prefixIcon: Icon(Icons.person_outline, color: cs.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text("Unassigned")),
                          ..._members.map((m) => DropdownMenuItem(
                            value: m['createdBy'],
                            child: Text(m['firstName'] ?? m['userName'] ?? 'User'),
                          )),
                        ],
                        onChanged: (val) => setState(() => _selectedMemberId = val),
                      ),
                    const SizedBox(height: 32),
                    FormSubmitButton(
                      loading: _isSaving,
                      onPressed: _saveShoppingItem,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

