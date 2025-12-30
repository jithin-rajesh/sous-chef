import 'package:flutter_test/flutter_test.dart';
import 'package:sous_chef/models/recipe_model.dart';

void main() {
  group('Recipe Parsing', () {
    test('parses logic complete JSON correctly', () {
      final json = {
        'id': '123',
        'title': 'Test Recipe',
        'ingredients': [
          {'name': 'Flour', 'amount': '1 cup'},
          {'name': 'Egg', 'amount': '1'}
        ],
        'steps': [
          {'step_index': 1, 'title': 'Mix', 'instruction': 'Mix it', 'timer_seconds': 60}
        ]
      };

      final recipe = Recipe.fromJson(json);
      expect(recipe.title, 'Test Recipe');
      expect(recipe.ingredients.length, 2);
      expect(recipe.steps.length, 1);
      expect(recipe.steps.first.timerSeconds, 60);
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'id': '124',
        'title': 'Incomplete Recipe',
        // 'ingredients' missing
        // 'steps' missing
      };

      final recipe = Recipe.fromJson(json);
      expect(recipe.title, 'Incomplete Recipe');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.steps, isEmpty);
    });

    test('handles type mismatches in steps', () {
      final json = {
        'id': '125',
        'title': 'Messy Types',
        'steps': [
          {
            'step_index': '1', // String instead of int
            'title': 'Intro',
            'instruction': 'Do this',
            'timer_seconds': '120' // String instead of int
          }
        ]
      };

      final recipe = Recipe.fromJson(json);
      expect(recipe.steps.first.stepIndex, 1);
      expect(recipe.steps.first.timerSeconds, 120);
    });
  });
}
