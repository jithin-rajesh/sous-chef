import 'dart:async';
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
  
  @override
  void dispose() {
    for (var t in _internalTimers.values) {
      t.cancel();
    }
    super.dispose();
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
