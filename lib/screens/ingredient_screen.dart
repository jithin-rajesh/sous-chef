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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                  recipe.title,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18, // Smaller font for collapsed state
                  ),
              ),
              background: Container(
                color: Colors.grey[200],
                child: Center(
                    child: Icon(Icons.restaurant_menu,
                        size: 80, color: Colors.grey[400])
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Consumer<RecipeProvider>(
              builder: (ctx, provider, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final ingredient = recipe.ingredients[i];
                      final isChecked = provider.isIngredientChecked(recipeId, ingredient.name);

                      return CheckboxListTile(
                        activeColor: Theme.of(context).primaryColor,
                        title: Text(
                          "${ingredient.amount} ${ingredient.name}",
                          style: TextStyle(
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: isChecked ? Colors.grey : Colors.black87,
                            fontSize: 18,
                            fontFamily: 'Lato',
                          ),
                        ),
                        value: isChecked,
                        onChanged: (val) {
                            provider.toggleIngredient(recipeId, ingredient.name);
                        },
                      );
                    },
                    childCount: recipe.ingredients.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Check padding
        ],
      ),
      floatingActionButton: Consumer<RecipeProvider>(
          builder: (ctx, provider, child) {
              final allChecked = provider.areAllIngredientsChecked(recipeId);
              
              return GestureDetector(
                  onLongPress: () {
                       Navigator.of(context).pushNamed(
                        CookingModeScreen.routeName,
                        arguments: recipeId,
                      );
                  },
                  child: FloatingActionButton.extended(
                    onPressed: allChecked ? () {
                        Navigator.of(context).pushNamed(
                            CookingModeScreen.routeName,
                            arguments: recipeId,
                        );
                    } : null,
                    backgroundColor: allChecked ? Theme.of(context).primaryColor : Colors.grey,
                    label: const Text("Start Cooking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
              );
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
