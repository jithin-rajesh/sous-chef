import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  // Map to track checked ingredients per recipe.
  // Key: recipeId, Value: Set of ingredient names that are checked.
  final Map<String, Set<String>> _checkedIngredients = {};

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/recipes.json');
      final List<dynamic> data = json.decode(response);
      _recipes = data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading recipes: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addRecipe(Recipe recipe) {
    _recipes.insert(0, recipe);
    notifyListeners();
  }

  bool isIngredientChecked(String recipeId, String ingredientName) {
    return _checkedIngredients[recipeId]?.contains(ingredientName) ?? false;
  }

  void toggleIngredient(String recipeId, String ingredientName) {
    if (!_checkedIngredients.containsKey(recipeId)) {
      _checkedIngredients[recipeId] = {};
    }

    if (_checkedIngredients[recipeId]!.contains(ingredientName)) {
      _checkedIngredients[recipeId]!.remove(ingredientName);
    } else {
      _checkedIngredients[recipeId]!.add(ingredientName);
    }
    notifyListeners();
  }

  bool areAllIngredientsChecked(String recipeId) {
    final recipe = _recipes.firstWhere((r) => r.id == recipeId);
    final checkedCount = _checkedIngredients[recipeId]?.length ?? 0;
    return checkedCount == recipe.ingredients.length;
  }
}
