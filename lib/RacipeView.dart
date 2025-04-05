import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_generator/Authantication/Authuser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeView extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeView({super.key, required this.recipe});

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  bool isInWishlist = false;
  int? customerId;

  @override
  void initState() {
    super.initState();
    loadCustomerId(); // Load customer ID from shared preferences
  }

  Future<void> loadCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id != null) {
      setState(() {
        customerId = id;
      });
      checkWishlistStatus(); // Check wishlist only after loading ID
    }
  }

  void checkWishlistStatus() async {
    if (customerId == null) return;

    final url = Uri.parse(
      "${ApiHelper().baseUrl}/wishlist/index.php?recipe_id=${widget.recipe['generate_id']}&customer_id=$customerId",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isInWishlist = data['exists'] == true;
        });
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error checking wishlist: $e");
    }
  }

  void toggleWishlist() async {
    if (customerId == null) return;

    final recipeId = widget.recipe['generate_id'];
    final url = Uri.parse(
      ApiHelper().baseUrl +
          (isInWishlist ? '/wishlist/delete.php' : '/wishlist/store.php'),
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "wishlist_genrate_resipe_id": recipeId,
          "wishlist_customer_id": customerId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] != null) {
        setState(() {
          isInWishlist = !isInWishlist;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['success']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Something went wrong'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Wishlist toggle error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.recipe['generate_name'] ?? 'Unknown Recipe',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
          centerTitle: true,
          elevation: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: toggleWishlist,
            ),
          ],
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final recipe = widget.recipe;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/food3.jpg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoTile(Icons.access_time, recipe['generate_preparation_time'] ?? 'N/A'),
                _infoTile(Icons.group, recipe['generate_servings_count'] ?? 'N/A'),
                _infoTile(Icons.local_fire_department, recipe['generate_kcal'] ?? 'N/A'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: TabBar(
              labelColor: Colors.green.shade700,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.green.shade700,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Description'),
                Tab(text: 'Ingredients'),
                Tab(text: 'Instructions'),
                Tab(text: 'Nutrition'),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _tabCard(recipe['generate_description'] ?? 'No description available.'),
                _tabCard(recipe['generate_ingredients'] ?? 'No ingredients listed.'),
                _tabCard(recipe['generate_instructions'] ?? 'No instructions provided.'),
                _tabCard(recipe['generate_nutritions'] ?? 'No nutritional info available.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 28),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _tabCard(String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
