import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeView extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Description, Ingredients, Instructions, Nutrition
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            recipe['generate_name'] ?? 'Unknown Recipe',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
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
          // backgroundColor: Colors.green.shade700, // Beautiful AppBar color
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Recipe Image with Title
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

              // Recipe Info (Time, Serving, Calories)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoTile(Icons.access_time, recipe['generate_preparation_time'] ?? 'N/A'),
                    _infoTile(Icons.group, recipe['generate_servings_count'] ?? 'N/A'),
                    _infoTile(Icons.local_fire_department, recipe['generate_kcal']??'N/A'),
                  ],
                ),
              ),

              // TabBar
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

              // Scrollable TabBarView
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6, // Adjust height dynamically
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(), // Prevent nested scroll conflicts
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
        ),
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
          // border: Border.all(color: Colors.green.shade400, width: 2),
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
