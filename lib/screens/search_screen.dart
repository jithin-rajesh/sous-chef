import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_provider.dart';
import 'recipe_preview_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Ensure raw recipes are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRawRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access provider logic
    final provider = context.watch<RecipeProvider>();
    final rawRecipes = provider.searchResults;
    final isLoading = provider.isLoadingRaw;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for biryani, paneer, etc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchRawRecipes('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                provider.searchRawRecipes(value);
              },
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (rawRecipes.isEmpty && _searchController.text.isNotEmpty)
             Expanded(
              child: Center(
                child: Text(
                  'No recipes found.',
                  style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: rawRecipes.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final recipe = rawRecipes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        recipe.name,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${recipe.ingredients.length} ingredients • ${recipe.instructions.length} steps',
                        style: GoogleFonts.dmSans(color: Colors.grey.shade600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                        // Navigate to Preview Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipePreviewScreen(rawRecipe: recipe),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }
}
