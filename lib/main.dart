import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/recipe_provider.dart';
import 'screens/home_screen.dart';
import 'screens/ingredient_screen.dart';
import 'screens/cooking_mode_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SousChefApp());
}

class SousChefApp extends StatelessWidget {
  const SousChefApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'Sous Chef',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFFFFAB40), // Soft Saffron
          scaffoldBackgroundColor: const Color(0xFFFDFBF7), // Warm Cream
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFFFFAB40),
            secondary: const Color(0xFFFFAB40),
            surface: const Color(0xFFFDFBF7),
            surfaceContainerHighest: const Color(0xFFFFE0B2), // Light Orange/Cream for inputs
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
            ),
          ),
          textTheme: TextTheme(
            displayLarge: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
              letterSpacing: -0.5,
            ),
            titleLarge: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
              letterSpacing: -0.5,
            ),
            bodyLarge: GoogleFonts.dmSans(
              fontSize: 17, // Apple Standard Body Size
              color: const Color(0xFF333333),
              height: 1.4,
            ),
            bodyMedium: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF666666),
              height: 1.4,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFFDFBF7),
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFF2D2D2D)),
            titleTextStyle: GoogleFonts.dmSans(
              color: const Color(0xFF2D2D2D),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFAB40),
              foregroundColor: const Color(0xFF4A3423), // Darker brown text for contrast
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Stadium Shape
              ),
              textStyle: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            hintStyle: GoogleFonts.dmSans(
              color: Colors.black38,
              fontSize: 16,
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          IngredientScreen.routeName: (ctx) => const IngredientScreen(),
          CookingModeScreen.routeName: (ctx) => const CookingModeScreen(),
        },
      ),
    );
  }
}
