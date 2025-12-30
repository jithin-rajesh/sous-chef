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

  @override
  Widget build(BuildContext context) {
    final recipeData = Provider.of<RecipeProvider>(context);
    final recipes = recipeData.recipes;

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
      body: Column(
        children: [
          // Quick Add Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipeInputController,
                    decoration: const InputDecoration(
                      hintText: 'Paste recipe url or text here',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isParsing
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _handleQuickAdd,
                        icon: const Icon(Icons.send),
                        color: Colors.orange, // Saffron Orange roughly
                        tooltip: 'Parse Recipe',
                      ),
              ],
            ),
          ),
          Expanded(
            child: recipeData.isLoading
                ? const Center(child: CircularProgressIndicator())
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
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
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
      ),
    );
  }
}
