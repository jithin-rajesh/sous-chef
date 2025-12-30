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
          primaryColor: const Color(0xFFFF9933), // Saffron Orange
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFFFF9933),
            secondary: const Color(0xFFFF9933),
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
            displayLarge: GoogleFonts.zenDots(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            titleLarge: GoogleFonts.zenDots(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            bodyLarge: GoogleFonts.openSans(
              fontSize: 18,
              color: Colors.black87,
            ),
            bodyMedium: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: GoogleFonts.zenDots(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
