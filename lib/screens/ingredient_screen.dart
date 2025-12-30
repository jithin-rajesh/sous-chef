import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import 'cooking_mode_screen.dart';

class IngredientScreen extends StatelessWidget {
  static const routeName = '/ingredients';

  const IngredientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeId = ModalRoute.of(context)!.settings.arguments as String;
    final recipe = Provider.of<RecipeProvider>(context, listen: false)
        .recipes
        .firstWhere((r) => r.id == recipeId);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (ctx, provider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: recipe.ingredients.length,
                  itemBuilder: (ctx, i) {
                    final ingredient = recipe.ingredients[i];
                    final isChecked = provider.isIngredientChecked(recipeId, ingredient.name);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isChecked
                                ? Theme.of(context).primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: CheckboxListTile(
                        activeColor: Theme.of(context).primaryColor,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          "${ingredient.amount} ${ingredient.name}",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isChecked ? Colors.grey.shade400 : Colors.black87,
                                fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                              ),
                        ),
                        value: isChecked,
                        onChanged: (val) {
                          provider.toggleIngredient(recipeId, ingredient.name);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<RecipeProvider>(
        builder: (ctx, provider, child) {
          final allChecked = provider.areAllIngredientsChecked(recipeId);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FloatingActionButton.extended(
                elevation: 0,
                highlightElevation: 0,
                onPressed: () {
                    // Always allow cooking, just highlight if ready? 
                    // User request implied flow, but usually user wants to start even if not all checked.
                    // But original logic was strict. Let's keep it strict but maybe allow override?
                    // For now, keep usage logic but style it.
                    if (allChecked) {
                      Navigator.of(context).pushNamed(
                        CookingModeScreen.routeName,
                        arguments: recipeId,
                      );
                    }
                },
                backgroundColor: allChecked ? Theme.of(context).primaryColor : Colors.grey.shade300,
                foregroundColor: allChecked ? Colors.white : Colors.grey.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                label: Text(
                  allChecked ? "Start Cooking" : "Gather Ingredients",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                icon: Icon(Icons.play_arrow_rounded, color: allChecked ? Colors.white : Colors.grey.shade600),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
