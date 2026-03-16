import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/suggest_item_details.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../injection_container.dart';
import '../../../setting/presentation/language_cubit.dart';

@RoutePage()
class EditItemPage extends StatefulWidget {
  final InventoryItem item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController noteController;
  late String selectedCategory;
  late String selectedUnit;
  bool isSummarizingNote = false;

  String _normalizeCategory(String raw) {
    final value = raw.trim();
    final lower = value.toLowerCase();

    if (lower == 'drink' || lower == 'beverage' || lower == 'beverages') {
      return 'Drink';
    }

    // Legacy categories (e.g. Meat/Dairy/Fruits) -> Food
    return 'Food';
  }

  String _normalizeUnit(String raw) {
    final value = raw.trim();
    final lower = value.toLowerCase();

    if (lower == 'pcs' || lower == 'pc' || lower == 'piece' || lower == 'pieces') {
      return 'pcs';
    }
    if (lower == 'bottle' || lower == 'bottles') return 'bottle';
    if (lower == 'ml' || lower == 'milliliter' || lower == 'milliliters') {
      return 'ml';
    }
    if (lower == 'g' || lower == 'gram' || lower == 'grams') return 'g';
    if (lower == 'kg' || lower == 'kilogram' || lower == 'kilograms') {
      return 'kg';
    }
    if (lower == 'l' || lower == 'lt' || lower == 'liter' || lower == 'litre') {
      return 'liter';
    }

    // Default fallback to pcs to keep dropdown stable.
    return 'pcs';
  }

  String _mergeNotesWithAiSummary(String? rawUserNotes, String aiSummary) {
    final userNotes = (rawUserNotes ?? '').trim();
    final summary = aiSummary.trim();

    if (userNotes.isEmpty) return summary;
    if (summary.isEmpty) return userNotes;

    return '$userNotes\n\n$summary';
  }

  String _removeExistingAiSummary(String text) {
    final trimmed = text.trimRight();
    if (trimmed.isEmpty) return trimmed;

    final titleThai = AppStrings.aiSummaryTitle;
    final titleOther = titleThai == 'สรุปจาก AI' ? 'AI Summary' : 'สรุปจาก AI';

    final indexThai = trimmed.lastIndexOf(titleThai);
    final indexOther = trimmed.lastIndexOf(titleOther);
    final index = indexThai > indexOther ? indexThai : indexOther;

    if (index < 0) return trimmed;
    return trimmed.substring(0, index).trimRight();
  }

  String _buildAiSummaryText(Map<String, String> data) {
    final category = (data['category'] ?? '').trim();
    final duration = (data['duration'] ?? '').trim();
    final tips = (data['tips'] ?? '').trim();

    final parts = <String>[];
    if (category.isNotEmpty) parts.add('${AppStrings.category}: $category');
    if (duration.isNotEmpty) parts.add('${AppStrings.durationLabel}: $duration');
    if (tips.isNotEmpty) parts.add('${AppStrings.tipsLabel}: $tips');

    if (parts.isEmpty) return '';
    return '${AppStrings.aiSummaryTitle}\n${parts.join('\n')}';
  }

  Future<void> summarizeNoteWithAi() async {
    if (!_formKey.currentState!.validate()) return;
    if (isSummarizingNote) return;

    final name = nameController.text.trim();

    setState(() {
      isSummarizingNote = true;
    });

    try {
      final suggest = sl<SuggestItemDetails>();
      final cleanedNotes = _removeExistingAiSummary(noteController.text);
      final notesForAi = cleanedNotes.trim().isEmpty ? null : cleanedNotes.trim();

      final result = await suggest(name, selectedCategory, notesForAi);
      result.fold(
        (failure) {
          debugPrint('AI note summary failed: ${failure.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppStrings.aiSummaryFailed}: ${failure.message}'),
              ),
            );
          }
        },
        (data) {
          final aiSummary = _buildAiSummaryText(data);
          if (aiSummary.isEmpty) return;

          final merged = _mergeNotesWithAiSummary(notesForAi, aiSummary);
          noteController.text = merged;
        },
      );
    } catch (e) {
      debugPrint('AI note summary exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.aiSummaryFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSummarizingNote = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    noteController = TextEditingController(text: widget.item.notes ?? '');
    selectedCategory = _normalizeCategory(widget.item.category);
    selectedUnit = _normalizeUnit(widget.item.unit);
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void updateItem() {
    if (!_formKey.currentState!.validate()) return;
    if (isSummarizingNote) return;

    final updatedItem = InventoryItem(
      id: widget.item.id,
      name: nameController.text.trim(),
      barcode: widget.item.barcode,
      category: selectedCategory,
      quantity: int.parse(quantityController.text.trim()),
      unit: selectedUnit,
      imagePath: widget.item.imagePath,
      expiryDate: widget.item.expiryDate,
      createdAt: widget.item.createdAt,
      updatedAt: DateTime.now(),
      notes: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      isFood: selectedCategory == 'Food',
    );

    context.read<InventoryBloc>().add(AddInventoryItem(updatedItem));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editItem), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.itemName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterItemName;
                  }
                  if (value.length < 2) {
                    return AppStrings.itemNameMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<LanguageCubit, AppLanguage>(
                builder: (context, language) {
                  return DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: AppStrings.category,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Food',
                        child: Text(AppStrings.categoryFood),
                      ),
                      DropdownMenuItem(
                        value: 'Drink',
                        child: Text(AppStrings.categoryDrink),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => selectedCategory = newValue);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.quantity,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterQuantity;
                  }
                  if (int.tryParse(value) == null) {
                    return AppStrings.quantityMustBeNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedUnit,
                decoration: InputDecoration(
                  labelText: AppStrings.unit,
                  border: const OutlineInputBorder(),
                ),
                items: ['pcs', 'bottle', 'ml', 'g', 'kg', 'liter'].map((
                  String unit,
                ) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => selectedUnit = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppStrings.notes,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSummarizingNote ? null : summarizeNoteWithAi,
                  icon: isSummarizingNote
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isSummarizingNote
                        ? AppStrings.summarizingWithAi
                        : AppStrings.summarizeWithAi,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSummarizingNote ? null : updateItem,
                  icon: const Icon(Icons.check),
                  label: Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
