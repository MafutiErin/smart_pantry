import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_state.dart';
import '../../domain/usecases/suggest_menu_from_pantry.dart';
import '../../../../injection_container.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../setting/presentation/language_cubit.dart';

@RoutePage()
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<ChatMessage> messages = [];
  final scrollController = ScrollController();
  final messageController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    final state = context.read<InventoryBloc>().state;
    if (state is! InventoryLoaded) {
      setState(() {
        messages.add(
          ChatMessage(
            text: userMessage,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        messages.add(
          ChatMessage(
            text: AppStrings.connectionIssue,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
      messageController.clear();
      return;
    }

    // Detect language from user message
    context.read<LanguageCubit>().detectAndSetLanguage(userMessage);

    setState(() {
      isLoading = true;
      messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
    });

    messageController.clear();
    _scrollToBottom();

    try {
      final suggestMenuUseCase = sl<SuggestMenuFromPantry>();
      final itemNames = state.items.map((item) => item.name).toList();

      if (itemNames.isEmpty) {
        setState(() {
          messages.add(
            ChatMessage(
              text: AppStrings.pantryEmpty,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }

      // Add loading message while waiting for response
      setState(() {
        messages.add(
          ChatMessage(
            text: AppStrings.thinking,
            isUser: false,
            timestamp: DateTime.now(),
            isLoading: true,
          ),
        );
      });
      _scrollToBottom();

      final suggestions = await suggestMenuUseCase(
        itemNames,
        userMessage: userMessage,
      );

      // Replace loading message with actual response
      setState(() {
        messages.removeLast();
        messages.add(
          ChatMessage(
            text: suggestions,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        isLoading = false;
      });

      _scrollToBottom();
    } catch (_) {
      // Show error message to user
      setState(() {
        messages.removeLast(); // Remove loading message
        messages.add(
          ChatMessage(
            text: AppStrings.connectionIssue,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<LanguageCubit, AppLanguage>(
      listener: (context, state) {
        setState(() {}); // Rebuild with new language
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant_menu, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.aiMenuAssistant,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.smartKitchenHelper,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: colorScheme.surface,
          actions: [
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppStrings.currentLanguage == AppLanguage.thai
                          ? '🇹🇭'
                          : '🇬🇧',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Chat messages
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppStrings.welcomeToAIChef,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.askAboutRecipes,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              _buildSuggestionChips(context),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageBubble(message, context);
                      },
                    ),
            ),

            // Loading indicator
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.aiChefIsThinking,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // Input area
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        enabled: !isLoading,
                        onSubmitted: (value) {
                          _sendMessage(value);
                        },
                        decoration: InputDecoration(
                          hintText: AppStrings.askAboutRecipesHint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: isLoading
                          ? null
                          : () => _sendMessage(messageController.text),
                      elevation: 4,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      mini: true,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: message.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.smart_toy,
                        size: 20,
                        color: colorScheme.primary,
                      ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    maxLines: null,
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isUser
                          ? colorScheme.onPrimary.withValues(alpha: 0.6)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final suggestions = [
      AppStrings.whatCanICook,
      AppStrings.healthyRecipes,
      AppStrings.quickMeals,
      AppStrings.dessertIdeas,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return FilledButton.tonal(
          onPressed: () => _sendMessage(suggestion),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.primary,
          ),
          child: Text(suggestion),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });
}
