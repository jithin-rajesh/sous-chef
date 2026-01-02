import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_parser_service.dart';
import '../models/recipe_model.dart';
// We might not need to import RecipeDetailScreen/CookingModeScreen if we just pop back or replace,
// but let's assume we want to view it.
import 'cooking_mode_screen.dart'; 
import 'ingredient_screen.dart';

class RecipePreviewScreen extends StatefulWidget {
  final RawRecipe rawRecipe;

  const RecipePreviewScreen({Key? key, required this.rawRecipe}) : super(key: key);

  @override
  State<RecipePreviewScreen> createState() => _RecipePreviewScreenState();
}

class _RecipePreviewScreenState extends State<RecipePreviewScreen> {
  bool _isParsing = false;
  Future<void> _cookThisRecipe() async {
    _performParsing();
  }

  Future<void> _performParsing() async {
    setState(() => _isParsing = true);
    try {
       final parser = RecipeParserService();
       // No API key needed client-side, handled by Cloud Function
       final parsedRecipe = await parser.parseRecipe(widget.rawRecipe.toFullText());
       
       if (!mounted) return;
       
       // Add to provider
       context.read<RecipeProvider>().addRecipe(parsedRecipe);
       
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Recipe parsed! Added to your collection.')),
       );
       
       // Navigate to Ingredients Screen
       Navigator.of(context).pushReplacementNamed(
         IngredientScreen.routeName,
         arguments: parsedRecipe.id,
       );
       
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Preview'),
      ),
      body: _isParsing 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Chefs are analyzing the recipe...', style: GoogleFonts.dmSans()),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    widget.rawRecipe.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  if (widget.rawRecipe.url.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.rawRecipe.url,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Ingredients Section
                  Text(
                    'Ingredients',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.rawRecipe.ingredients.map((ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: Color(0xFFFFAB40)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${ing.amount} ${ing.unit} ${ing.ingredient}',
                            style: GoogleFonts.dmSans(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions Section
                  Text(
                    'Instructions',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   const SizedBox(height: 12),
                  ...widget.rawRecipe.instructions.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFAB40).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$index',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: GoogleFonts.dmSans(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
      bottomNavigationBar: !_isParsing ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _cookThisRecipe,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFFFAB40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Cook This Recipe',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ) : null,
    );
  }
}
