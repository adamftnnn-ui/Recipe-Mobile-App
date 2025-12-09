import '../services/api_service.dart';

class ChatRepository {
  Future<String> getConverseReply(String text, String contextId) async {
    try {
      final response = await ApiService.converseWithSpoonacular(
        text,
        contextId,
      );
      return response?['answer']?.toString() ?? 'Maaf, AI tidak merespon.';
    } catch (e) {
      // Jaga agar UI tidak crash kalau ada error jaringan / parsing
      return 'Maaf, terjadi kesalahan saat menghubungi AI.';
    }
  }

  Future<Map<String, dynamic>?> getRecipe(String query) async {
    try {
      final encoded = Uri.encodeQueryComponent(query);
      final result = await ApiService.getData(
        'recipes/complexSearch?query=$encoded&number=1&addRecipeInformation=true',
      );
      return result;
    } catch (e) {
      // Kembalikan null supaya controller bisa handle sebagai "tidak ada data"
      return null;
    }
  }
}
