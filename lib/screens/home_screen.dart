import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_parser_service.dart';
import '../services/api_key_service.dart';
import 'ingredient_screen.dart';

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
  final ApiKeyService _apiKeyService = ApiKeyService();
  bool _isParsing = false;

  @override
  void dispose() {
    _recipeInputController.dispose();
    super.dispose();
  }

  Future<void> _showApiKeyDialog() async {
    final TextEditingController _apiKeyController = TextEditingController();
    final currentKey = await _apiKeyService.getApiKey();
    if (currentKey != null) {
      _apiKeyController.text = currentKey;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To use the AI recipe parser, you need a Google Gemini API Key.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'Paste your API Key here',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = _apiKeyController.text.trim();
              if (key.isNotEmpty) {
                await _apiKeyService.saveApiKey(key);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key saved!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuickAdd() async {
    final text = _recipeInputController.text.trim();
    if (text.isEmpty) return;

    // Check for API Key first
    String? apiKey = await _apiKeyService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key required. Please enter it in Settings.'),
            duration: Duration(seconds: 2),
          ),
        );
        _showApiKeyDialog();
      }
      return;
    }

    setState(() {
      _isParsing = true;
    });

    try {
      final recipe = await _recipeParserService.parseRecipe(text, apiKey);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildSearchTab(),
          _buildSavedTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Add a New Recipe',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _recipeInputController,
                    decoration: InputDecoration(
                      hintText: 'Paste your Recipe URL or text',
                      filled: true,
                      fillColor: const Color(0xFFFFF4C2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isParsing
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: () async {
                              await _handleQuickAdd();
                              // Switch to saved tab on success if not parsing anymore (and no error theoretically)
                              // Simple check: if text is cleared, it was likely successful
                              if (_recipeInputController.text.isEmpty) {
                                setState(() {
                                  _selectedIndex = 2; // Switch to Saved
                                });
                              }
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Parse Recipe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
    return const Center(
      child: Text('Search Feature Coming Soon'),
    );
  }

  Widget _buildSavedTab() {
    final recipeData = Provider.of<RecipeProvider>(context);
    final recipes = recipeData.recipes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Saved Recipes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: recipeData.isLoading
              ? const Center(child: CircularProgressIndicator())
              : recipes.isEmpty 
                ? const Center(child: Text('No saved recipes yet.'))
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (ctx, i) {
                    final recipe = recipes[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                        ),
                        subtitle: Text('${recipe.ingredients.length} ingredients • ${recipe.steps.length} steps'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            IngredientScreen.routeName,
                            arguments: recipe.id,
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
