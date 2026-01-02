import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    if (_checkedIngredients[recipeId] == null) return false;
    
    return recipe.ingredients.every((ingredient) => 
      _checkedIngredients[recipeId]!.contains(ingredient.name));
  }

  void toggleAllIngredients(String recipeId, bool value) {
    final recipe = _recipes.firstWhere((r) => r.id == recipeId);
    if (!_checkedIngredients.containsKey(recipeId)) {
      _checkedIngredients[recipeId] = {};
    }

    if (value) {
      // Select All
      for (var ingredient in recipe.ingredients) {
        _checkedIngredients[recipeId]!.add(ingredient.name);
      }
    } else {
      // Deselect All
      _checkedIngredients[recipeId]!.clear();
    }
    notifyListeners();
  }

  // --- Global Timer Logic ---
  final Map<String, TimerState> _activeTimers = {};
  final Map<String, Timer> _internalTimers = {};

  Map<String, TimerState> get activeTimers => _activeTimers;

  TimerState? getTimer(String timerId) => _activeTimers[timerId];

  void initializeTimer(String timerId, int seconds) {
    if (!_activeTimers.containsKey(timerId)) {
      _activeTimers[timerId] = TimerState(
        id: timerId,
        remainingSeconds: seconds,
        initialSeconds: seconds,
      );
      notifyListeners();
    }
  }

  void startTimer(String timerId) {
    if (!_activeTimers.containsKey(timerId)) return;

    final currentState = _activeTimers[timerId]!;
    if (currentState.isRunning) return;

    _activeTimers[timerId] = currentState.copyWith(isRunning: true);
    notifyListeners();

    _internalTimers[timerId]?.cancel();
    _internalTimers[timerId] = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = _activeTimers[timerId];
      if (state == null) {
        timer.cancel();
        return;
      }

      if (state.remainingSeconds > 0) {
        _activeTimers[timerId] = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
        notifyListeners();
      } else {
        timer.cancel();
        _activeTimers[timerId] = state.copyWith(
          isRunning: false,
          isCompleted: true,
        );
        notifyListeners();
        // Here we could trigger a sound or notification
      }
    });
  }

  void pauseTimer(String timerId) {
    _internalTimers[timerId]?.cancel();
    if (_activeTimers.containsKey(timerId)) {
      _activeTimers[timerId] = _activeTimers[timerId]!.copyWith(isRunning: false);
      notifyListeners();
    }
  }

  void resetTimer(String timerId) {
    _internalTimers[timerId]?.cancel();
    if (_activeTimers.containsKey(timerId)) {
      final initial = _activeTimers[timerId]!.initialSeconds;
      _activeTimers[timerId] = TimerState(
        id: timerId,
        remainingSeconds: initial,
        initialSeconds: initial,
        isRunning: false,
        isCompleted: false,
      );
      notifyListeners();
    }
  }
  
  // --- Raw Recipe / Search Logic ---
  List<RawRecipe> _rawRecipes = [];
  List<RawRecipe> _searchResults = [];
  bool _isLoadingRaw = false;

  List<RawRecipe> get searchResults => _searchResults;
  bool get isLoadingRaw => _isLoadingRaw;

  Future<void> loadRawRecipes() async {
    if (_rawRecipes.isNotEmpty) return;

    _isLoadingRaw = true;
    notifyListeners();

    try {
      // Connect to emulator in debug mode (Optional: better to do in main.dart, but here for ensuring)
      /* 
       * Note: Ideally emulator connection is set up once in main.dart.
       * Assuming user follows the guide to setup emulator connection as typically done.
       * But to be safe, we can try to use `FirebaseFunctions.instance.useFunctionsEmulator` if not globally set.
       * However, typically this is done in main(). I will assume main() will be updated or user knows.
       */
       
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getRawRecipes');
      final result = await callable.call();
      
      final List<dynamic> data = result.data;
      _rawRecipes = data.map((json) => RawRecipe.fromJson(Map<String, dynamic>.from(json))).toList();
      
    } catch (e) {
      debugPrint("Error loading raw recipes from Cloud: $e");
      // Fallback removed to enforce server-side source.
      throw Exception("Failed to load recipes from server: $e");
    } finally {
      _isLoadingRaw = false;
      notifyListeners();
    }
  }

  void searchRawRecipes(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = _rawRecipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (var t in _internalTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}

class RawRecipe {
  final String name;
  final String url;
  final List<RawIngredient> ingredients;
  final List<String> instructions;

  RawRecipe({
    required this.name,
    required this.url,
    required this.ingredients,
    required this.instructions,
  });

  factory RawRecipe.fromJson(Map<String, dynamic> json) {
    return RawRecipe(
      name: json['name'] as String? ?? 'Unknown Recipe',
      url: json['url'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => RawIngredient.fromJson(e))
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String toFullText() {
    final buffer = StringBuffer();
    buffer.writeln('Title: $name');
    buffer.writeln('\nIngredients:');
    for (var ing in ingredients) {
      buffer.writeln('- ${ing.amount} ${ing.unit} ${ing.ingredient}');
    }
    buffer.writeln('\nInstructions:');
    for (var i = 0; i < instructions.length; i++) {
      buffer.writeln('${i + 1}. ${instructions[i]}');
    }
    return buffer.toString();
  }
}

class RawIngredient {
  final double amount;
  final String unit;
  final String ingredient;

  RawIngredient({
    required this.amount,
    required this.unit,
    required this.ingredient,
  });

  factory RawIngredient.fromJson(Map<String, dynamic> json) {
    return RawIngredient(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      ingredient: json['ingredient'] as String? ?? '',
    );
  }
}

class TimerState {
  final String id;
  final int remainingSeconds;
  final int initialSeconds;
  final bool isRunning;
  final bool isCompleted;

  TimerState({
    required this.id,
    required this.remainingSeconds,
    required this.initialSeconds,
    this.isRunning = false,
    this.isCompleted = false,
  });

  TimerState copyWith({
    String? id,
    int? remainingSeconds,
    int? initialSeconds,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return TimerState(
      id: id ?? this.id,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
