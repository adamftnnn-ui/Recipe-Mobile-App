import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';

class ChatController {
  final ChatRepository repository = ChatRepository();
  final ValueNotifier<List<ChatMessage>> chatsNotifier = ValueNotifier([]);

  final String userAvatar = 'assets/images/avatar.jpg';
  final String assistantAvatar = 'assets/images/avatar_ai.jpg';
  final String userName = 'Adam';
  final String assistantName = 'Kama';

  String _contextId = '342938'; // Context ID default dari Spoonacular

  void addInitialGreeting(BuildContext context) {
    chatsNotifier.value = [
      ChatMessage(
        avatarUrl: assistantAvatar,
        name: assistantName,
        role: 'Assistant',
        message:
            'Halo $userName, apa yang ingin kamu tanyakan atau masak hari ini?',
        time: TimeOfDay.now().format(context),
        isAssistant: true,
      ),
    ];
  }

  void addUserMessage(String text, BuildContext context) {
    final message = ChatMessage(
      avatarUrl: userAvatar,
      name: userName,
      message: text,
      time: TimeOfDay.now().format(context),
      isAssistant: false,
    );
    chatsNotifier.value = [...chatsNotifier.value, message];
  }

  void addAssistantMessage(String text, BuildContext context) {
    final message = ChatMessage(
      avatarUrl: assistantAvatar,
      name: assistantName,
      role: 'Assistant',
      message: text,
      time: TimeOfDay.now().format(context),
      isAssistant: true,
    );
    chatsNotifier.value = [...chatsNotifier.value, message];
  }

  Future<void> getAssistantReply(
    String userMessage,
    BuildContext context,
  ) async {
    try {
      final keyword = userMessage.toLowerCase();
      final recipeKeywords = [
        'resep',
        'burger',
        'ayam',
        'nasi',
        'sop',
        'ikan',
        'cake',
        'kue',
      ];
      final isRecipeQuery = recipeKeywords.any((k) => keyword.contains(k));

      if (isRecipeQuery) {
        await _fetchRecipe(userMessage, context);
      } else {
        await _fetchConverseReply(userMessage, context);
      }
    } catch (e) {
      addAssistantMessage('Maaf, terjadi kesalahan.', context);
    }
  }

  Future<void> _fetchRecipe(String userMessage, BuildContext context) async {
    try {
      final result = await repository.getRecipe(userMessage);
      if (result != null &&
          result.containsKey('results') &&
          (result['results'] as List).isNotEmpty) {
        final item = result['results'][0];
        final title = item['title'] ?? 'Resep Tanpa Judul';
        final ready = item['readyInMinutes'] ?? '-';
        final servings = item['servings'] ?? '-';
        final ingredients = (item['extendedIngredients'] as List? ?? [])
            .map((e) => e['original']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        String reply =
            '**$title**\nPorsi: $servings\nWaktu masak: $ready menit\nBahan:\n';
        for (var ing in ingredients) {
          reply += '- $ing\n';
        }
        addAssistantMessage(reply.trim(), context);
      } else {
        addAssistantMessage(
          'Maaf, saya tidak menemukan resep untuk "$userMessage".',
          context,
        );
      }
    } catch (e) {
      addAssistantMessage(
        'Maaf, terjadi kesalahan saat mengambil resep.',
        context,
      );
    }
  }

  Future<void> _fetchConverseReply(
    String userMessage,
    BuildContext context,
  ) async {
    try {
      final replyText = await repository.getConverseReply(
        userMessage,
        _contextId,
      );
      addAssistantMessage(replyText, context);
      // Update contextId jika API mengembalikan yang baru (opsional)
      // _contextId = response?['contextId'] ?? _contextId;
    } catch (e) {
      addAssistantMessage('Maaf, terjadi kesalahan pada AI.', context);
    }
  }
}
