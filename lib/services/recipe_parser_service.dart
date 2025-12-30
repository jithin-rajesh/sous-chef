import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe_model.dart';

class RecipeParserService {
  Future<Recipe> parseRecipe(String text, String apiKey) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
Convert this recipe text into valid JSON matching this schema: 
{ 
  "title": string, 
  "ingredients": [{"name": string, "amount": string}], 
  "steps": [{"step_index": int, "title": string, "instruction": string, "timer_seconds": int or null}] 
}. 
Return ONLY raw JSON, no markdown formatting.

Recipe Text: $text
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      String? jsonString = response.text;
      
      if (jsonString == null) {
        throw Exception('Empty response from Gemini');
      }

      // Clean up potential markdown code blocks
      jsonString = jsonString.replaceAll(RegExp(r'```json\n?'), '').replaceAll(RegExp(r'```'), '').trim();

      final Map<String, dynamic> data = json.decode(jsonString);
      
      return Recipe.fromJson(data);

    } catch (e) {
      print('Gemini Parser Error: $e');
      throw Exception('Failed to parse recipe. Please check your API key and try again.');
    }
  }
}