import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/recipe_model.dart';

class RecipeParserService {
  Future<Recipe> parseRecipe(String text) async {
    // API Key is handled by Cloud Function environment variable.
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('parseRecipeWithGemini');
      final result = await callable.call(<String, dynamic>{
        'text': text,
      });

      final Map<String, dynamic> data = Map<String, dynamic>.from(result.data);
      return Recipe.fromJson(data);

    } catch (e) {
      debugPrint('Cloud Function Parser Error: $e');
      throw Exception('Failed to parse recipe via Cloud. Please ensure backend is running.');
    }
  }
}