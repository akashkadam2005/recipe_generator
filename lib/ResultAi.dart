import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'GeminiService.dart';

class ResultPage extends StatefulWidget {
  final Map<String, String> selectedData;

  const ResultPage({super.key, required this.selectedData});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String aiDescription = "Fetching description...";
  String aiIngredients = "Fetching ingredients...";
  String aiInstructions = "Fetching instructions...";
  String aiNutrition = "Fetching nutrition...";
  String aiImage = "";
  String aiKcal = "";
  String aiPrepTime = "";
  String aiServingsCount = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAIResponse();
  }

  Future<void> fetchAIResponse() async {
    print("Fetching AI response...");

    try {
      GeminiService geminiService = GeminiService();
      Map<String, String> response = await geminiService.fetchAIResponse(widget.selectedData);

      print("Response received: $response"); // Debugging print

      String fullText = response['text'] ?? "No data received.";

      // Extract sections using RegExp
      RegExp titleRegExp = RegExp(r'Title:\s*(.*)');
      RegExp ingredientsRegExp = RegExp(r'Ingredients:\s*([\s\S]*?)(?=\n\n|Instructions:|Nutrition Information:|$)');
      RegExp instructionsRegExp = RegExp(r'Instructions:\s*([\s\S]*?)(?=\n\n|Nutrition Information:|$)');
      RegExp nutritionRegExp = RegExp(r'Nutrition Information:\s*([\s\S]*)');

      String title = titleRegExp.firstMatch(fullText)?.group(1)?.trim() ?? "No title";
      String ingredients = ingredientsRegExp.firstMatch(fullText)?.group(1)?.trim() ?? "No ingredients found.";
      String instructions = instructionsRegExp.firstMatch(fullText)?.group(1)?.trim() ?? "No instructions found.";
      String nutrition = nutritionRegExp.firstMatch(fullText)?.group(1)?.trim() ?? "No nutrition info found.";

      // Extract Calories
      RegExp kcal = RegExp(r'Calories\s*\(kcal\):\s*(?:Approximately\s*)?(\d+)', caseSensitive: false);
      String extractedCalories = kcal.firstMatch(nutrition)?.group(1) ?? "Unknown";

      print("Extracted Calories: $extractedCalories"); // Should print only "350"

      setState(() {
        aiKcal = extractedCalories;  // Stores only the kcal number (e.g., "350")
      });



      // Extract Preparation Time & Servings Count
      RegExp prepTimeRegExp = RegExp(r'Preparation Time:\s*(\d+)\s*Mins');
      RegExp servingsRegExp = RegExp(r'Servings Count:\s*(\d+)');

      String prepTime = prepTimeRegExp.firstMatch(fullText)?.group(1) ?? "Unknown";
      String servingsCount = servingsRegExp.firstMatch(fullText)?.group(1) ?? "Unknown";

      print("Parsed Title: $title");
      print("Parsed Ingredients: $ingredients");
      print("Parsed Instructions: $instructions");
      print("Parsed Nutrition: $nutrition");
      print("Extracted Calories: $kcal");
      print("Extracted Preparation Time: $prepTime Mins");
      print("Extracted Servings Count: $servingsCount");

      setState(() {
        aiDescription = title;
        aiIngredients = ingredients;
        aiInstructions = instructions;
        aiNutrition = nutrition;
        aiPrepTime = prepTime;
        aiServingsCount = servingsCount;
        isLoading = false;
      });

    } catch (e) {
      print("Error fetching recipe: $e");

      setState(() {
        aiDescription = "Error fetching recipe: $e";
        aiIngredients = "Error loading ingredients.";
        aiInstructions = "Error loading instructions.";
        aiNutrition = "Error loading nutritional info.";
        aiKcal = "";
        aiPrepTime = "";
        aiServingsCount = "";
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print("Selected Data: ${widget.selectedData}");
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Generated Recipe",
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
        ),
        body: SingleChildScrollView(
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
                        image: DecorationImage(
                          image:
                          // aiImage.isNotEmpty && Uri.parse(aiImage).isAbsolute
                              // ? NetworkImage(aiImage)
                               AssetImage("assets/images/food3.jpg") as ImageProvider,
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
                  if (isLoading)
                    const Positioned.fill(
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoTile(Icons.access_time, widget.selectedData['Preparation Time'] ?? 'Unknown'),
                    _infoTile(Icons.group, widget.selectedData['Servings Count'] ?? 'Unknown'),
                    _infoTile(Icons.local_fire_department, aiKcal ?? 'Unknown'),

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
                    _tabCard(aiDescription), // Description
                    _tabCard(aiIngredients), // Ingredients
                    _tabCard(aiInstructions), // Instructions
                    _tabCard(aiNutrition),    // Nutrition
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
