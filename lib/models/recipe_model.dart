class Recipe {
  final String id;
  final String title;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? DateTime.now().toString(), // Fallback ID
      title: json['title'] as String? ?? 'Untitled Recipe',
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => Ingredient.fromJson(i))
              .toList() ??
          [],
      steps: (json['steps'] as List?)
              ?.map((s) => Step.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class Ingredient {
  final String name;
  final String amount;

  Ingredient({required this.name, required this.amount});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? 'Unknown Ingredient',
      amount: json['amount'].toString(), // Handle both string and int/double
    );
  }
}

class Step {
  final int stepIndex;
  final String title;
  final String instruction;
  final int? timerSeconds;

  Step({
    required this.stepIndex,
    required this.title,
    required this.instruction,
    this.timerSeconds,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      stepIndex: json['step_index'] is int
          ? json['step_index'] as int
          : int.tryParse(json['step_index'].toString()) ?? 0,
      title: json['title'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      timerSeconds: json['timer_seconds'] is int
          ? json['timer_seconds'] as int
          : int.tryParse(json['timer_seconds']?.toString() ?? ''),
    );
  }
}
