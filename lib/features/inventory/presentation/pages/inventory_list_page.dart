import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inventory_item.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../../../setting/presentation/theme_cubit.dart';
import '../../../setting/presentation/language_cubit.dart';
import '../../../setting/presentation/ai_provider_cubit.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../app/router/app_router.dart';

enum _InventoryMenuAction {
  languageThai,
  languageEnglish,
  aiGemini,
  aiOpenAi,
  toggleTheme,
}

enum _InventoryItemMenuAction { edit, delete }

@RoutePage()
class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  String _normalizeCategory(String raw) {
    final value = raw.trim();
    final lower = value.toLowerCase();
    if (lower == 'drink' || lower == 'beverage' || lower == 'beverages') {
      return 'Drink';
    }
    // Any other/legacy categories -> Food.
    return 'Food';
  }

  String _displayCategory(String raw) {
    final normalized = _normalizeCategory(raw);
    return normalized == 'Drink' ? AppStrings.categoryDrink : AppStrings.categoryFood;
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
    return value;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Load inventory items when page initializes
    Future.microtask(() {
      if (mounted) {
        context.read<InventoryBloc>().add(LoadInventory());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _dashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color baseColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 140, maxHeight: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withValues(alpha: isDark ? 0.22 : 0.18),
              baseColor.withValues(alpha: isDark ? 0.06 : 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: isDark ? 0.12 : 0.14),
              blurRadius: 14,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: isDark ? 0.18 : 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: baseColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: baseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List<InventoryItem> items) {
    final totalItems = items.length;
    final lowStockItems = items.where((e) => e.quantity <= 2).length;
    final expiringItems = items.where((e) => e.quantity <= 1).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<LanguageCubit, AppLanguage>(
            builder: (context, language) {
              return Text(
                AppStrings.dashboard,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<LanguageCubit, AppLanguage>(
                  builder: (context, language) {
                    return _dashboardCard(
                      context,
                      AppStrings.totalItems,
                      totalItems.toString(),
                      Icons.inventory_2_outlined,
                      const Color(0xFF1E88E5),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<LanguageCubit, AppLanguage>(
                  builder: (context, language) {
                    return _dashboardCard(
                      context,
                      AppStrings.lowStock,
                      lowStockItems.toString(),
                      Icons.warning_amber_rounded,
                      const Color(0xFFFFA000),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<LanguageCubit, AppLanguage>(
                  builder: (context, language) {
                    return _dashboardCard(
                      context,
                      AppStrings.runningOut,
                      expiringItems.toString(),
                      Icons.timer_outlined,
                      const Color(0xFFE53935),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToAddItem(BuildContext context) {
    context.router.push(const AddItemRoute());
  }

  void _goToEditItem(BuildContext context, InventoryItem item) {
    context.router.push(EditItemRoute(item: item));
  }

  void _openDetail(BuildContext context, InventoryItem item, int index) {
    context.router.push(ItemDetailRoute(item: item, index: index));
  }

  void _goToAiChat(BuildContext context) {
    context.router.push(const AIChatRoute());
  }

  Future<bool> _confirmDeleteDialog(
    BuildContext context,
    InventoryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.delete),
        content: Text('${AppStrings.deleteConfirm} "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _deleteItem(BuildContext context, InventoryItem item) async {
    final confirmed = await _confirmDeleteDialog(context, item);

    if (!confirmed || !context.mounted || item.id == null) return;

    context.read<InventoryBloc>().add(DeleteInventoryItem(itemId: item.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} ${AppStrings.deleted}')),
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    if (_searchQuery.isEmpty) {
      return items;
    }
    return items
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (item.barcode != null &&
                  item.barcode!.isNotEmpty &&
                  item.barcode!.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  )),
        )
        .toList();
  }

  List<InventoryItem> _filterByCategory(
    List<InventoryItem> items,
    String? category,
  ) {
    if (category == null) return items;
    return items.where((e) => _normalizeCategory(e.category) == category).toList();
  }

  Widget _buildLoadedTab(
    BuildContext context,
    List<InventoryItem> allItems,
    String? category,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryItems = _filterByCategory(allItems, category);
    final filteredItems = _filterItems(categoryItems);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildDashboard(context, categoryItems)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: BlocBuilder<LanguageCubit, AppLanguage>(
              builder: (context, language) {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.search,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        if (filteredItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: BlocBuilder<LanguageCubit, AppLanguage>(
                builder: (context, language) {
                  return Text(
                    _searchQuery.isEmpty
                        ? AppStrings.noItems
                        : AppStrings.noSearchResults,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: colorScheme.onSurface),
                  );
                },
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredItems[index];
                  final heroTag = 'item-header-$index';

                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 10,
                    ),
                    child: BlocBuilder<LanguageCubit, AppLanguage>(
                      builder: (context, language) {
                        return Dismissible(
                          key: ValueKey(item.id ?? '${item.name}-$index'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) =>
                              _confirmDeleteDialog(context, item),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            if (item.id == null) return;

                            context.read<InventoryBloc>().add(
                                  DeleteInventoryItem(itemId: item.id!),
                                );

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item.name} ${AppStrings.deleted}',
                                ),
                                action: SnackBarAction(
                                  label: AppStrings.undo,
                                  onPressed: () {
                                    context.read<InventoryBloc>().add(
                                          AddInventoryItem(item),
                                        );
                                  },
                                ),
                              ),
                            );
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openDetail(context, item, index),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Hero(
                                  tag: heroTag,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      item.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  '${AppStrings.quantityLabel}: ${item.quantity} ${_normalizeUnit(item.unit)} • ${_displayCategory(item.category)}',
                                ),
                                trailing:
                                    PopupMenuButton<_InventoryItemMenuAction>(
                                  onSelected: (action) {
                                    switch (action) {
                                      case _InventoryItemMenuAction.edit:
                                        _goToEditItem(context, item);
                                        return;
                                      case _InventoryItemMenuAction.delete:
                                        _deleteItem(context, item);
                                        return;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: _InventoryItemMenuAction.edit,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit, size: 20),
                                          const SizedBox(width: 8),
                                          Text(AppStrings.edit),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: _InventoryItemMenuAction.delete,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppStrings.delete,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 88)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final aiProvider = context.watch<AiProviderCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.kitchen_outlined,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<LanguageCubit, AppLanguage>(
                builder: (context, language) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.inventoryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<_InventoryMenuAction>(
            onSelected: (action) {
              switch (action) {
                case _InventoryMenuAction.languageThai:
                  context.read<LanguageCubit>().setLanguage(AppLanguage.thai);
                  break;
                case _InventoryMenuAction.languageEnglish:
                  context
                      .read<LanguageCubit>()
                      .setLanguage(AppLanguage.english);
                  break;
                case _InventoryMenuAction.aiGemini:
                  context.read<AiProviderCubit>().setProvider(AiProvider.gemini);
                  break;
                case _InventoryMenuAction.aiOpenAi:
                  context.read<AiProviderCubit>().setProvider(AiProvider.openai);
                  break;
                case _InventoryMenuAction.toggleTheme:
                  context.read<ThemeCubit>().toggleTheme();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _InventoryMenuAction.languageThai,
                child: Row(
                  children: [const Text('🇹🇭 '), Text(AppStrings.thai)],
                ),
              ),
              PopupMenuItem(
                value: _InventoryMenuAction.languageEnglish,
                child: Row(
                  children: [const Text('🇬🇧 '), Text(AppStrings.english)],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _InventoryMenuAction.aiGemini,
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 18,
                      color: aiProvider == AiProvider.gemini
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.aiProviderGemini),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _InventoryMenuAction.aiOpenAi,
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: aiProvider == AiProvider.openai
                          ? colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(AppStrings.aiProviderOpenAi),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _InventoryMenuAction.toggleTheme,
                child: Row(
                  children: [
                    Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(themeMode == ThemeMode.dark
                        ? AppStrings.lightMode
                        : AppStrings.darkMode),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.more_vert),
            ),
          ),
          IconButton(
            tooltip: 'AI Chat',
            onPressed: () {
              _goToAiChat(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chat, color: colorScheme.secondary, size: 20),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your pantry...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (state is InventoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            );
          }
          if (state is InventoryLoaded) {
            final allItems = state.items;

            return BlocBuilder<LanguageCubit, AppLanguage>(
              builder: (context, language) {
                final tabs = <({String label, String? category})>[
                  (label: AppStrings.categoryAll, category: null),
                  (label: AppStrings.categoryFood, category: 'Food'),
                  (label: AppStrings.categoryDrink, category: 'Drink'),
                ];

                return DefaultTabController(
                  length: tabs.length,
                  child: Column(
                    children: [
                      Material(
                        color: colorScheme.surface,
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: colorScheme.primary,
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurfaceVariant,
                          tabs: [
                            for (final tab in tabs) Tab(text: tab.label),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: TabBarView(
                          children: [
                            for (final tab in tabs)
                              _buildLoadedTab(context, allItems, tab.category),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // Fallback for any other state (including InventoryInitial)
          // This ensures the page tries to load if no specific state matched
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading your pantry...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddItem(context),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
