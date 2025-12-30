import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_provider.dart';
import '../widgets/timer_widget.dart';

class CookingModeScreen extends StatefulWidget {
  static const routeName = '/cooking';

  const CookingModeScreen({Key? key}) : super(key: key);

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final recipeId = ModalRoute.of(context)!.settings.arguments as String;
    final recipe = Provider.of<RecipeProvider>(context, listen: false)
        .recipes
        .firstWhere((r) => r.id == recipeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / recipe.steps.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Step ${_currentStep + 1} of ${recipe.steps.length}",
              style: GoogleFonts.lato(color: Colors.grey, fontSize: 14),
            ),
          ),
          
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: recipe.steps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemBuilder: (ctx, i) {
                final step = recipe.steps[i];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        step.instruction,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 48),
                      if (step.timerSeconds != null)
                        TimerWidget(seconds: step.timerSeconds!),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    if (_currentStep > 0)
                        TextButton(
                            onPressed: () {
                                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            },
                            child: const Text("Back")
                        )
                    else 
                        const SizedBox(width: 64), // spacer

                    if (_currentStep < recipe.steps.length - 1)
                        ElevatedButton(
                            onPressed: () {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            },
                             style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                            ),
                            child: const Text("Next Step")
                        )
                    else
                        ElevatedButton(
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                            ),
                            child: const Text("Finish Cooking!")
                        )
                ],
            ),
        )
      ),
    );
  }
}
