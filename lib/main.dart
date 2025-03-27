import 'package:flutter/material.dart';
import 'package:recipe_generator/Authantication/Login.dart';
import 'package:recipe_generator/Authantication/demo.dart';
import 'package:recipe_generator/Home.dart';
import 'package:recipe_generator/Setting.dart';
import 'package:recipe_generator/SplashScreen.dart';
import 'package:recipe_generator/Recipes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Generator',
      theme: ThemeData.light(), // Light Mode Theme
      darkTheme: ThemeData.dark(), // Dark Mode Theme
      themeMode: ThemeMode.system, // Uses system setting
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    RecipesScreen(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.9), // Glass effect
          elevation: 10,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue.shade900,
          unselectedItemColor: Colors.grey,
          selectedIconTheme: IconThemeData(size: 30), // Enlarge selected icon
          unselectedIconTheme: IconThemeData(size: 24), // Normal size
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Fixes shifting behavior
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: "AI Generator",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: "Recipes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),

    );
  }
}
