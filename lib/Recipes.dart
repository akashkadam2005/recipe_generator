import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipe_generator/Authantication/Authuser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Home.dart';
import 'RacipeView.dart';
import 'Setting.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  _RecipesScreenState createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;
  int? customerId;

  @override
  void initState() {
    super.initState();
    fetchCustomerIdAndRecipes();
  }

  /// ✅ Fetch Customer ID from SharedPreferences
  Future<void> fetchCustomerIdAndRecipes() async {
    customerId = await getCustomerId();

    if (customerId == null) {
      print("No customer ID found in SharedPreferences.");
      setState(() => isLoading = false);
      return;
    }

    print("✅ Fetched Customer ID: $customerId");
    await getRecipes(customerId!);
  }

  /// ✅ Get Customer ID Safely
  Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /// ✅ Fetch Recipes from API
  Future<void> getRecipes(int customerId) async {
    try {
      final response =
      await ApiHelper().httpGet("genrate/show.php?customer_id=$customerId");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            recipes = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });

          print("✅ Recipes Fetched: ${recipes.length} recipes");
        } else {
          setState(() => isLoading = false);
          print("❌ API Response Error: ${data['message']}");
        }
      } else {
        setState(() => isLoading = false);
        print("❌ API Request Failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching recipes: $e");
    }
  }

  /// ✅ **Delete Recipe API Call**
  Future<void> deleteRecipe(String generateId) async {
    try {
      final response =
      await ApiHelper().httpDelete("genrate/delete.php?generate_id=$generateId");

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Raw Response Body: ${response.body}");

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains("application/json") == true) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            recipes.removeWhere((r) => r['generate_id'] == generateId);
          });

          Fluttertoast.showToast(
            msg: "✅ Recipe deleted successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          showErrorToast(data['message']);
        }
      } else {
        showErrorToast("❌ Invalid server response.");
      }
    } catch (e) {
      showErrorToast("🚨 Error deleting recipe: $e");
    }
  }

  /// ✅ Show Error Toast
  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Saved Recipes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
          ? const Center(child: Text("No recipes found!"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return buildRecipeCard(recipes[index]);
          },
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 1,
      //   selectedItemColor: Colors.blue.shade900,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: IconButton(
      //             onPressed: () {
      //               Navigator.pushReplacement(
      //                   context, MaterialPageRoute(builder: (context) => HomePage()));
      //             },
      //             icon: const Icon(Icons.auto_awesome)),
      //         label: "AI Generator"),
      //     BottomNavigationBarItem(
      //         icon: IconButton(
      //             onPressed: () {
      //               Navigator.pushReplacement(
      //                   context, MaterialPageRoute(builder: (context) => RecipesScreen()));
      //             },
      //             icon: const Icon(Icons.receipt_long)),
      //         label: "Recipes"),
      //     BottomNavigationBarItem(
      //         icon: IconButton(
      //             onPressed: () {
      //               Navigator.pushReplacement(
      //                   context, MaterialPageRoute(builder: (context) => SettingsPage()));
      //             },
      //             icon: const Icon(Icons.settings)),
      //         label: "Settings"),
      //   ],
      // ),
    );
  }

  /// ✅ Build Recipe Card
  Widget buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeView(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage("assets/images/logologin.jpg"), // Default image
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  recipe['generate_name'] ?? 'Unknown Recipe',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  bool confirmDelete = await showDeleteConfirmationDialog(context);
                  if (confirmDelete) {
                    await deleteRecipe(recipe['generate_id']);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Show Confirmation Dialog**
Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete Recipe"),
        content: const Text("Are you sure you want to delete this recipe?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  ) ??
      false;
}
