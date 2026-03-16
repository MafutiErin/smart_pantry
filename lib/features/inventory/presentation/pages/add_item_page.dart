import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_pantry_inventory/injection_container.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/identify_item_from_label.dart';
import '../../domain/usecases/lookup_product_by_barcode.dart';
import '../../domain/usecases/suggest_item_details.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../../../setting/presentation/language_cubit.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../app/router/app_router.dart';

@RoutePage()
class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final barcodeController = TextEditingController();
  final quantityController = TextEditingController();
  final noteController = TextEditingController();

  String selectedCategory = 'Food';
  String selectedUnit = 'pcs';
  bool isFood = true;
  bool isLookingUp = false;
  bool isExtractingText = false;
  bool isIdentifyingItem = false;
  bool isSummarizingNote = false;
  String? lastOcrText;
  int? lastConfidence;

  @override
  void dispose() {
    nameController.dispose();
    barcodeController.dispose();
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _identifyItemFromLabel() async {
    final ocr = lastOcrText;
    if (ocr == null || ocr.trim().isEmpty) return;
    if (isIdentifyingItem) return;

    setState(() {
      isIdentifyingItem = true;
      lastConfidence = null;
    });

    try {
      final identify = sl<IdentifyItemFromLabel>();
      final result = await identify(ocr);

      result.fold(
        (failure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppStrings.aiIdentificationFailed}: ${failure.message}')),
          );
        },
        (data) {
          if (!mounted) return;

          final name = (data['name'] ?? '').trim();
          final category = (data['category'] ?? '').trim();
          final unit = (data['unit'] ?? '').trim();
          final quantity = (data['quantity'] ?? '').trim();
          final confidenceStr = (data['confidence'] ?? '').trim();
          final confidence = int.tryParse(confidenceStr);

          setState(() {
            if (name.isNotEmpty) {
              nameController.text = name;
            }

            if (quantity.isNotEmpty && int.tryParse(quantity) != null) {
              quantityController.text = quantity;
            }

            if (unit.isNotEmpty) {
              selectedUnit = unit;
            }

            if (category.isNotEmpty) {
              selectedCategory = category;
              isFood = category == 'Food';
            }

            lastConfidence = confidence;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.aiIdentificationFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isIdentifyingItem = false;
        });
      }
    }
  }

  String _sanitizeOcrText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  int? _extractFirstInt(String text) {
    final match = RegExp(r'\b(\d{1,5})\b').firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  String? _extractUnit(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('kg') || normalized.contains('กก')) return 'kg';
    if (normalized.contains('pack') || normalized.contains('แพ็ก')) return 'pack';
    if (normalized.contains('bottle') || normalized.contains('ขวด') ||
        normalized.contains('ml') || normalized.contains('l ')) {
      return 'bottle';
    }
    if (normalized.contains('pcs') || normalized.contains('piece') ||
        normalized.contains('ชิ้น')) {
      return 'pcs';
    }
    return null;
  }

  String? _extractLikelyName(String text) {
    final lines = text
        .split(RegExp(r'[\n\r]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    // Prefer a short-ish line with letters and not mostly digits
    for (final line in lines) {
      final cleaned = line.replaceAll(RegExp(r'[^\p{L}\p{N} ]', unicode: true), '').trim();
      if (cleaned.length < 2) continue;
      final digitCount = RegExp(r'\d').allMatches(cleaned).length;
      if (digitCount > cleaned.length / 2) continue;
      if (cleaned.length <= 40) return cleaned;
    }
    return _sanitizeOcrText(lines.first);
  }

  Future<void> _extractTextFromImage(ImageSource source) async {
    if (isExtractingText) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      isExtractingText = true;
    });

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(picked.path);
      final recognized = await recognizer.processImage(inputImage);
      final rawText = recognized.text;
      final cleanedText = _sanitizeOcrText(rawText);
      if (cleanedText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.textExtractionFailed)),
          );
        }
        return;
      }

      final name = _extractLikelyName(rawText);
      final qty = _extractFirstInt(rawText);
      final unit = _extractUnit(rawText);

      if (mounted) {
        setState(() {
          noteController.text = cleanedText;
          lastOcrText = rawText;
          lastConfidence = null;
          if ((name ?? '').trim().isNotEmpty) {
            nameController.text = name!.trim();
          }
          if (qty != null && qty > 0) {
            quantityController.text = qty.toString();
          }
          if (unit != null) {
            selectedUnit = unit;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.textExtractionFailed}: $e')),
        );
      }
    } finally {
      await recognizer.close();
      if (mounted) {
        setState(() {
          isExtractingText = false;
        });
      }
    }
  }

  Future<void> _scanBarcode() async {
    final result = await context.router.push(const BarcodeScannerRoute());
    final code = result is String ? result : null;

    if (code != null) {
      setState(() {
        barcodeController.text = code;
      });

      await _lookupProductName();
    }
  }

  Future<void> _lookupProductName() async {
    final barcode = barcodeController.text.trim();
    if (barcode.isEmpty) return;

    setState(() {
      isLookingUp = true;
    });

    try {
      final lookup = sl<LookupProductByBarcode>();
      final result = await lookup(barcode);

      if (result.status == 1 && result.product != null) {
        final product = result.product!;

        if ((product.productName ?? '').trim().isNotEmpty) {
          nameController.text = product.productName!.trim();
        }

        final qtyText = product.packageQuantity?.toLowerCase() ?? '';
        if (qtyText.contains('ml') || qtyText.contains('l')) {
          selectedUnit = 'bottle';
          selectedCategory = 'Drink';
          isFood = false;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.productNotFoundFromBarcode)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text('${AppStrings.lookupFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLookingUp = false;
        });
      }
    }
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

    final titleThai = AppStrings.aiSummaryTitle; // language-aware
    final titleOther = titleThai == 'สรุปจาก AI' ? 'AI Summary' : 'สรุปจาก AI';

    final indexThai = trimmed.lastIndexOf(titleThai);
    final indexOther = trimmed.lastIndexOf(titleOther);
    final index = indexThai > indexOther ? indexThai : indexOther;

    if (index < 0) return trimmed;

    // Remove from the title to the end.
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
              SnackBar(content: Text('${AppStrings.aiSummaryFailed}: ${failure.message}')),
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

  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (isSummarizingNote) return;

    final name = nameController.text.trim();

    final rawNotes = noteController.text;
    final String? finalNotes = rawNotes.trim().isEmpty ? null : rawNotes.trim();

    final item = InventoryItem(
      name: name,
      barcode: barcodeController.text.trim().isEmpty
          ? null
          : barcodeController.text.trim(),
      category: selectedCategory,
      quantity: int.parse(quantityController.text.trim()),
      unit: selectedUnit,
      imagePath: null,
      expiryDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: finalNotes,
      isFood: isFood,
    );

    if (!mounted) return;
    context.read<InventoryBloc>().add(AddInventoryItem(item));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addItem),
        actions: [
          IconButton(
            tooltip: AppStrings.extractTextFromImage,
            onPressed: isExtractingText
                ? null
                : () async {
                    final source = await showModalBottomSheet<ImageSource>(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt_outlined),
                                title: Text(AppStrings.takePhoto),
                                onTap: () => Navigator.pop(context, ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library_outlined),
                                title: Text(AppStrings.chooseFromGallery),
                                onTap: () => Navigator.pop(context, ImageSource.gallery),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (source != null) {
                      await _extractTextFromImage(source);
                    }
                  },
            icon: isExtractingText
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.text_snippet_outlined),
          ),
          PopupMenuButton<AppLanguage>(
            onSelected: (language) {
              context.read<LanguageCubit>().setLanguage(language);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: AppLanguage.thai,
                child: Row(
                  children: [const Text('🇹🇭 '), Text(AppStrings.thai)],
                ),
              ),
              PopupMenuItem(
                value: AppLanguage.english,
                child: Row(
                  children: [const Text('🇬🇧 '), Text(AppStrings.english)],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.language),
            ),
          ),
        ],
      ),
      body: BlocListener<LanguageCubit, AppLanguage>(
        listener: (context, state) {
          setState(() {}); // Rebuild form when language changes
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (isExtractingText)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(AppStrings.extractingText)),
                      ],
                    ),
                  ),
                if (lastOcrText != null && (lastOcrText ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isIdentifyingItem ? null : _identifyItemFromLabel,
                          icon: isIdentifyingItem
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            isIdentifyingItem
                                ? AppStrings.identifyingItem
                                : AppStrings.identifyWithAI,
                          ),
                        ),
                        if (lastConfidence != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${AppStrings.confidenceLabel}: $lastConfidence%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
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
                    if (value.trim().length < 2) {
                      return AppStrings.itemNameMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: barcodeController,
                  decoration: InputDecoration(
                    labelText: AppStrings.barcode,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
                          opacity: isLookingUp ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedScale(
                            scale: isLookingUp ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 300),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _lookupProductName,
                          icon: const Icon(Icons.search),
                          tooltip: AppStrings.lookupProduct,
                        ),
                        IconButton(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: AppStrings.scanBarcode,
                        ),
                      ],
                    ),
                  ),
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
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.enterQuantity;
                    }

                    final quantity = int.tryParse(value.trim());
                    if (quantity == null) {
                      return AppStrings.quantityMustBeNumber;
                    }
                    if (quantity <= 0) {
                      return AppStrings.quantityMustBeGreaterThanZero;
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
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedCategory = value;
                          isFood = value == 'Food';
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<LanguageCubit, AppLanguage>(
                  builder: (context, language) {
                    return DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      decoration: InputDecoration(
                        labelText: AppStrings.unit,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'pcs',
                          child: Text(AppStrings.unitPcs),
                        ),
                        DropdownMenuItem(
                          value: 'bottle',
                          child: Text(AppStrings.unitBottle),
                        ),
                        DropdownMenuItem(
                          value: 'pack',
                          child: Text(AppStrings.unitPack),
                        ),
                        DropdownMenuItem(
                          value: 'kg',
                          child: Text(AppStrings.unitKg),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedUnit = value;
                        });
                      },
                    );
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSummarizingNote ? null : saveItem,
                    icon: isSummarizingNote
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(AppStrings.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
