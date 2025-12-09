import '../models/recipe_model.dart';
import '../services/api_service.dart';

class DetailRecipeController {
  RecipeModel recipe;
  bool isLoaded = false;

  DetailRecipeController({required dynamic recipeData})
    : recipe = _initRecipe(recipeData);

  /// Normalisasi data awal menjadi RecipeModel
  static RecipeModel _initRecipe(dynamic data) {
    // 1. Kalau sudah RecipeModel (mis. dari Trending) → pakai langsung
    if (data is RecipeModel) {
      return data;
    }

    // 2. Kalau Map, coba ambil original_data / original dari repository
    if (data is Map<String, dynamic>) {
      final dynamic original = data['original_data'] ?? data['original'];

      if (original is Map<String, dynamic>) {
        // Map lengkap dari API (punya extendedIngredients, dll)
        return RecipeModel.fromMap(original);
      }

      // Kalau nggak ada original_data, pakai map itu sebisanya
      return RecipeModel.fromMap(data);
    }

    // 3. Fallback aman
    return RecipeModel.fromMap(null);
  }

  /// Ambil detail terbaru dari API berdasarkan recipe.id
  Future<void> fetchRecipeFromApi() async {
    final int id = recipe.id;
    if (id == 0) {
      // Tidak ada id valid, cukup pakai data lokal saja
      return;
    }

    final data = await ApiService.getRecipeDetail(id);
    if (data != null) {
      recipe = RecipeModel.fromMap(data);
      isLoaded = true;
    } else {
      // Gagal fetch, biarkan pakai data lokal
    }
  }

  List<String> getIngredients() => recipe.ingredients;

  List<String> getInstructions() => recipe.instructions;

  Map<String, String> getNutrition() => recipe.nutrition;
}
