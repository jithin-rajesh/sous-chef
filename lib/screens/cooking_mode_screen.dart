import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        title: Text(
          "Step ${_currentStep + 1} of ${recipe.steps.length}",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        leading: CloseButton(color: Theme.of(context).primaryColor),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / recipe.steps.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  minHeight: 8,
                ),
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Control via buttons
                itemCount: recipe.steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemBuilder: (ctx, i) {
                  final step = recipe.steps[i];
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            step.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 36,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            step.instruction,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 48),
                          if (step.timerSeconds != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: TimerWidget(seconds: step.timerSeconds!),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Control Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < recipe.steps.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic);
                        } else {
                          Navigator.of(context).pop(); // Done
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep < recipe.steps.length - 1 ? "Next Step" : "Finish Cooking!",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text("Back", style: TextStyle(fontSize: 16)),
                    )
                  else
                    const SizedBox(height: 48), // Spacer to keep layout stable
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
