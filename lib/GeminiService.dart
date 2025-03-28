import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/Authantication/Authuser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAPfyxq3Br8gralL6mPQQ7AK53EVlMutBU';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _backendApiUrl =
      'genrate/store.php'; // Backend API URL

  /// ✅ Fetch the Customer ID from SharedPreferences
  Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // Returns null if not found
  }

  /// ✅ Fetch AI-generated recipe with clean point-to-point format
  Future<Map<String, String>> fetchAIResponse(Map<String, String> selectedData) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl?key=$_apiKey');

      // 🔹 Extract user inputs with default values
      String mealType = selectedData['Meal Type'] ?? 'a random meal';
      String cuisines = selectedData['Cuisines'] ?? 'any';
      String difficulty = selectedData['Cooking Difficulty'] ?? 'any';
      String preparationTime = selectedData['Preparation Time'] ?? '30';
      String servingsCount = selectedData['Servings Count'] ?? '1';
      String desiredProducts = selectedData['Desired Products'] ?? 'No specific products selected';
      String unwantedProducts = selectedData['Unwanted Products'] ?? 'No specific products selected';

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text": "Generate a structured recipe for $mealType.\n\n"
                      "Cuisine: $cuisines\n"
                      "Difficulty: $difficulty\n"
                      "Preparation Time: $preparationTime minutes\n"
                      "Servings: $servingsCount\n"
                      "Desired Products: $desiredProducts\n"
                      "Unwanted Products: $unwantedProducts\n\n"
                      "### Format the response cleanly as:\n"
                      "Title: [Recipe Name]\n"
                      "Ingredients:\n"
                      "- [List ingredients without * or -]\n\n"
                      "Instructions:\n"
                      "1. [Numbered step-by-step guide]\n\n"
                      "Nutrition Information:\n"
                      "- Calories (kcal): [Value]\n"
                      "- [Other nutritional details]\n"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // 🔹 Validate response structure
        if (responseData['candidates'] == null || responseData['candidates'].isEmpty) {
          throw Exception("AI Response is empty.");
        }

        String textResponse = responseData['candidates'][0]['content']['parts'][0]['text'];

        // ✅ Extract AI-generated data dynamically
        Map<String, String> generatedRecipe = await extractRecipeData(textResponse, selectedData);

        // ✅ Unsplash image URL for the meal type
        String imageUrl = "https://source.unsplash.com/300x200/?$mealType";

        // ✅ Include the image and kcal values
        generatedRecipe['generate_image'] = imageUrl;

        // ✅ Send data to the database
        await sendRecipeToDatabase(generatedRecipe);

        return {
          "text": textResponse,
          "image": imageUrl,
        };
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        throw Exception("API returned error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      return {
        "text": "Error fetching recipe: $e",
        "image": "https://via.placeholder.com/300"
      };
    }
  }

  Future<String> _generateRecipeImage(Uri uri, String mealType, String cuisines) async {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Generate an image of $mealType, $cuisines food"}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['candidates'] == null || responseData['candidates'].isEmpty || responseData['candidates'][0]['content']['parts'] == null || responseData['candidates'][0]['content']['parts'].isEmpty) {
        throw Exception("Image generation failed.");
      }

      final imageUrl = responseData['candidates'][0]['content']['parts'][0]['inlineData']['data'];
      final decodedImage = base64Decode(imageUrl);
      final imageurlstring = 'data:image/jpeg;base64,$imageUrl';

      return imageurlstring;
    } else {
      throw Exception("Image generation API returned error: ${response.statusCode}");
    }
  }

  /// ✅ Extract structured recipe data dynamically including kcal
  Future<Map<String, String>> extractRecipeData(String aiText, Map<String, String> selectedData) async {
    List<String> lines = aiText.split('\n');
    String title = '';
    String ingredients = '';
    String instructions = '';
    String nutrition = '';
    String kcal = '';
    String protein = '';
    String carbs = '';
    String fat = '';

    bool isIngredients = false;
    bool isInstructions = false;
    bool isNutrition = false;

    // Extract Title
    RegExp titleRegExp = RegExp(r'Title:\s*(.*)');
    title = titleRegExp.firstMatch(aiText)?.group(1)?.trim() ?? 'No title found';

    for (String line in lines) {
      if (line.toLowerCase().contains("ingredients")) {
        isIngredients = true;
        isInstructions = false;
        isNutrition = false;
        continue;
      } else if (line.toLowerCase().contains("instructions")) {
        isIngredients = false;
        isInstructions = true;
        isNutrition = false;
        continue;
      } else if (line.toLowerCase().contains("nutrition")) {
        isIngredients = false;
        isInstructions = false;
        isNutrition = true;
        continue;
      }

      if (isIngredients) {
        ingredients += line + "\n";
      } else if (isInstructions) {
        instructions += line + "\n";
      } else if (isNutrition) {
        if (line.toLowerCase().contains("calories")) {
          kcal = RegExp(r'(\d+)').firstMatch(line)?.group(1) ?? "Unknown";
        }
        if (line.toLowerCase().contains("protein")) {
          protein = line.split(":").last.trim();
        }
        if (line.toLowerCase().contains("carbohydrates")) {
          carbs = line.split(":").last.trim();
        }
        if (line.toLowerCase().contains("fat")) {
          fat = line.split(":").last.trim();
        }
        nutrition += line + "\n";
      }
    }

    // 🔹 Get the Customer ID correctly from SharedPreferences
    int? customerId = await getCustomerId();
    String customerIdString = customerId != null ? customerId.toString() : '1';

    // 🔹 Dynamically generate the description using extracted title
    String dynamicDescription = title.isNotEmpty && title != 'No title found'
        ? title
        : "Enjoy a delicious ${selectedData['Meal Type'] ?? 'meal'} with a perfect blend of flavors.";

    return {
      "generate_name": selectedData['Meal Type'] ?? 'Generated Recipe',
      "generate_customer_id": customerIdString,
      "generate_cuisines": selectedData['Cuisines'] ?? 'Unknown',
      "generate_meal_type": selectedData['Meal Type'] ?? 'Unknown',
      "generate_cooking_difficulty": selectedData['Cooking Difficulty'] ?? 'Normal',
      "generate_preparation_time": selectedData['Preparation Time'] ?? '30',
      "generate_servings_count": selectedData['Servings Count'] ?? '1',
      "generate_desired_products": selectedData['Desired Products'] ?? 'No specific products selected',
      "generate_unwanted_products": selectedData['Unwanted Products'] ?? 'No specific products selected',
      "generate_description": title,  // Now uses the extracted title
      "generate_ingredients": ingredients.trim().isNotEmpty ? ingredients.trim() : "No ingredients found.",
      "generate_instructions": instructions.trim().isNotEmpty ? instructions.trim() : "No instructions found.",
      "generate_nutritions": nutrition.trim().isNotEmpty ? nutrition.trim() : "No nutritional data found.",
      "generate_kcal": kcal,
      "generate_protein": protein.isNotEmpty ? protein : "Unknown",
      "generate_carbohydrates": carbs.isNotEmpty ? carbs : "Unknown",
      "generate_fat": fat.isNotEmpty ? fat : "Unknown",
    };
  }

  /// ✅ Send recipe data to the backend
  Future<void> sendRecipeToDatabase(Map<String, String> recipeData) async {
    try {
      final response = await ApiHelper().httpPost(_backendApiUrl, recipeData);

      if (response.statusCode == 200) {
        print("Recipe saved successfully: ${response.body}");
      } else {
        print("Failed to save recipe: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error sending data to the database: $e");
    }
  }
}
