import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_parser_service.dart';
import 'ingredient_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load recipes once when home loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    });
  }

  final TextEditingController _recipeInputController = TextEditingController();
  final RecipeParserService _recipeParserService = RecipeParserService();
  bool _isParsing = false;

  @override
  void dispose() {
    _recipeInputController.dispose();
    super.dispose();
  }

  Future<void> _handleQuickAdd() async {
    final text = _recipeInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isParsing = true;
    });

    try {
      final recipe = await _recipeParserService.parseRecipe(text);
      if (!mounted) return;

      Provider.of<RecipeProvider>(context, listen: false).addRecipe(recipe);
      _recipeInputController.clear();
      
      Navigator.of(context).pushNamed(
        IngredientScreen.routeName,
        arguments: recipe.id,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isParsing = false;
        });
      }
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sous Chef'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildSearchTab(),
          _buildSavedTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home_rounded, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded, size: 28),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_rounded, size: 28),
              activeIcon: Icon(Icons.bookmark_rounded, size: 28),
              label: 'Saved',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Text(
                'What are we cooking?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _recipeInputController,
                    decoration: InputDecoration(
                      hintText: 'Paste recipe URL or text...',
                      hintStyle: GoogleFonts.dmSans(color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F7), // Apple-like light gray
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    maxLines: 6,
                    minLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: _isParsing
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              await _handleQuickAdd();
                              if (_recipeInputController.text.isEmpty) {
                                setState(() {
                                  _selectedIndex = 2; // Switch to Saved
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text('Parse Recipe'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return const SearchTab();
  }

  Widget _buildSavedTab() {
    final recipeData = Provider.of<RecipeProvider>(context);
    final recipes = recipeData.recipes;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Your Recipes',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34),
            ),
          ),
        ),
        recipes.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dining_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No saved recipes yet',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final recipe = recipes[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              IngredientScreen.routeName,
                              arguments: recipe.id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.title,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${recipe.ingredients.length} Ingredients • ${recipe.steps.length} Steps',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: recipes.length,
                ),
              ),
      ],
    );
  }
}
