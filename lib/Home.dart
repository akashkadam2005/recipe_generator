import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipe_generator/Authantication/Login.dart';
import 'package:recipe_generator/Desiredproduct.dart';
import 'package:recipe_generator/Setting.dart';
import 'package:recipe_generator/main.dart';

import 'Authantication/Authuser.dart';
import 'Recipes.dart';
import 'ResultAi.dart';
import 'package:http/http.dart' as http;

import 'UnWantedProduct.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String selectedCuisine = "";
  String selectedMealType = "";
  String selectedDifficulty = "";
  String selectedTime = "";
  String selectedServings = "";

  // String selectedCuisine = "";
  List<Map<String, dynamic>> cuisines = []; // ✅ Correct data type
  List<Map<String, dynamic>> mealTypes = [];
  List<Map<String, dynamic>> difficulties = [];
  List<Map<String, dynamic>> preparationTimes = [];
  List<Map<String, dynamic>> servingsCount = [];

  List<String> selectedProducts = [];
  List<String> selectedUnwantedProducts = [];
  @override
  void initState() {
    super.initState();
    fetchCuisines();
    fetchMealTypes();
    fetchDifficulties();
    fetchPreparationTimes();
    fetchServingsCount();
  }

  Future<void> fetchCuisines() async {
    try {
      final response = await ApiHelper().httpGet('cuisines/index.php');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            cuisines = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("API returned error: ${data['status']}");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cuisines: $e");
    }
  }

  Future<void> fetchMealTypes() async {
    try {
      final response = await ApiHelper().httpGet('mealtype/index.php');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            mealTypes = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("API returned error: ${data['status']}");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching meal types: $e");
    }
  }

  Future<void> fetchDifficulties() async {
    try {
      final response = await ApiHelper().httpGet('cookingdifficulty/index.php');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            difficulties = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("API returned error: ${data['status']}");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching cooking difficulties: $e");
    }
  }

  Future<void> fetchPreparationTimes() async {
    try {
      // final response = await http.get(Uri.parse('http://192.168.0.100/chefio/api/preparetime/index.php'));
      final response = await ApiHelper().httpGet('preparetime/index.php');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            preparationTimes = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("API returned error: ${data['status']}");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching preparation times: $e");
    }
  }

  Future<void> fetchServingsCount() async {
    try {
      final response = await ApiHelper().httpGet('servingcount/index.php');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            servingsCount = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("API returned error: ${data['status']}");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching servings count: $e");
    }
  }

  void navigateToDesiredProducts() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DesiredProductsPage(selectedProducts: selectedProducts),
      ),
    );

    if (result != null) {
      setState(() {
        selectedProducts = List<String>.from(result);
      });
    } else {
      // ✅ Clear if user cancels or no selection made
      setState(() {
        selectedProducts.clear();
      });
    }
  }

  void navigateToUnwantedProducts() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnwantedProductsPage(
            selectedUnwantedProducts: selectedUnwantedProducts),
      ),
    );

    if (result != null) {
      setState(() {
        selectedUnwantedProducts = List<String>.from(result);
      });
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 28), // ⚠️ Icon
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700, // 🔥 Strong red tone
        behavior: SnackBarBehavior.floating, // 🚀 Floating above UI
        margin: EdgeInsets.all(16), // 🌟 Space for rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ Smooth edges
        ),
        duration: Duration(seconds: 3), // ⏲️ Longer visibility
        elevation: 10, // 🌟 3D shadow effect
      ),
    );
  }

  int _currentIndex = 0; // Default index for RecipesScreen

  // Function to handle navigation logic with switch-case
  Widget _getSelectedScreen(int index) {
    switch (index) {
      case 0:
        return  HomePage();
      case 1:
        return  RecipesScreen();
      case 2:
        return  LoginPage();
      default:
        return  RecipesScreen(); // Default screen
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(children: [
        // Top Background
        SizedBox(
          height: 100,
        ),
        Positioned.fill(
          child: Stack(
            children: [
              /// 📌 Background Image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              /// 📌 Opacity Overlay
              Container(
                color: Colors.black.withOpacity(0.1), // Adjust opacity (0.0 - 1.0)
              ),
            ],
          ),
        ),


        SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
              ),

              Row(
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 24, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Cuisines",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Cuisines List
              // Cuisines List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Dynamically Loaded Cuisines from API
                    ...cuisines.map((cuisine) {
                      return buildOption(
                        cuisine['cuisines_name'] ?? 'Unknown',
                        selectedCuisine,
                        (val) => setState(() => selectedCuisine = val),
                        Icons.food_bank,
                        context, // ✅ Pass context here
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.fastfood,
                      size: 24, color: Theme.of(context).primaryColor),
                  SizedBox(width: 10),
                  Text(
                    "Meal Type",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Meal Type Options (Dynamic)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Dynamically Loaded Meal Types from API
                    ...mealTypes.map((mealType) {
                      return buildOption(
                        mealType['mealtype_name'] ?? 'Unknown',
                        selectedMealType,
                        (val) => setState(() => selectedMealType = val),
                        Icons.food_bank,
                        context, // ✅ Pass context here
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.local_dining,
                      size: 24, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Cooking Difficulty",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Cooking Difficulty Options (Dynamic)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Dynamically Loaded Cooking Difficulties from API
                    ...difficulties.map((difficulty) {
                      return buildOption(
                        difficulty['cookingdifficulty_name'] ?? 'Unknown',
                        selectedDifficulty,
                        (val) => setState(() => selectedDifficulty = val),
                        Icons.whatshot,
                        context,
                      );
                    }).toList(),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.timer,
                      size: 24,
                      color:
                          Theme.of(context).primaryColor), // Icon before text
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    "Preparation Time",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...preparationTimes.map((time) {
                      return buildOption(
                        time['preparetime_name'] ?? 'Unknown',
                        selectedTime,
                        (val) => setState(() => selectedTime = val),
                        Icons.access_time,
                        context,
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.people,
                      size: 24, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Servings Count",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Servings Count Options (Dynamic)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...servingsCount.map((serving) {
                      return buildOption(
                        serving['servingcount_name'] ?? 'Unknown',
                        selectedServings,
                        (val) => setState(() => selectedServings = val),
                        Icons.people,
                        context,
                      );
                    }).toList(),
                    SizedBox(height: 60),
                  ],
                ),
              ),
              Column(
                children: [
                  selectionCard(
                    title: "Desired Products",
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      // print("Desired Products Selected");
                      // Navigator.push(context, MaterialPageRoute(builder: (context)=>DesiredProductsPage()));
                      navigateToDesiredProducts();
                    },
                    context: context,
                  ),
                  selectionCard(
                    title: "Unwanted Products",
                    icon: Icons.remove_circle_outline,
                    onPressed: () {
                      // print("Unwanted Products Selected");
                      navigateToUnwantedProducts();
                    },
                    context: context,
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),

      ]),
      floatingActionButton: SizedBox(
        width: 180,
        height: 50,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.blue.shade900,
          onPressed: () {
            // Validation checks for all required fields
            if (selectedProducts.isEmpty) {
              showErrorSnackBar("Please select at least one desired product.");
              return;
            }

            if (selectedCuisine == null || selectedCuisine!.isEmpty) {
              showErrorSnackBar("Please select a cuisine.");
              return;
            }

            if (selectedMealType == null || selectedMealType!.isEmpty) {
              showErrorSnackBar("Please select a meal type.");
              return;
            }

            if (selectedDifficulty == null || selectedDifficulty!.isEmpty) {
              showErrorSnackBar("Please select a cooking difficulty.");
              return;
            }

            if (selectedTime == null || selectedTime!.isEmpty) {
              showErrorSnackBar("Please select preparation time.");
              return;
            }

            if (selectedServings == null || selectedServings!.isEmpty) {
              showErrorSnackBar("Please select the number of servings.");
              return;
            }

            // Collecting selected values
            Map<String, String> selectedData = {
              "Cuisines": selectedCuisine ?? "Any",
              "Meal Type": selectedMealType ?? "Any",
              "Cooking Difficulty": selectedDifficulty ?? "Medium",
              "Preparation Time": selectedTime ?? "30 mins",
              "Servings Count": selectedServings ?? "2",
              "Desired Products": selectedProducts.join(', '),
              "Unwanted Products": selectedUnwantedProducts.join(', '),
            };

            print("Generated Recipe: $selectedData");

            // Navigate to the result page with the selected data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(selectedData: selectedData),
              ),
            );
          },
          label: Text(
            "Generate ✨",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          icon: Icon(Icons.auto_awesome, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   selectedItemColor: Colors.blue.shade900,
      //   unselectedItemColor: Colors.grey,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: IconButton(
      //           onPressed: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => HomePage()));
      //           },
      //           icon: Icon(Icons.auto_awesome),
      //         ),
      //         label: "AI Generator"),
      //     BottomNavigationBarItem(
      //         icon: IconButton(
      //           onPressed: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => RecipesScreen()));
      //           },
      //           icon: Icon(Icons.receipt_long),
      //         ),
      //         label: "Recipes"),
      //     BottomNavigationBarItem(
      //         icon: IconButton(
      //           onPressed: () {
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (context) => SettingsPage()));
      //           },
      //           icon: Icon(Icons.settings),
      //         ),
      //         label: "Settings"),
      //   ],
      // ),

    );
  }
}

Widget selectionCard({
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
  required BuildContext context,
}) {
  return Container(
    margin: EdgeInsets.symmetric(
      vertical: 10,
    ),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text("Select", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Widget buildOption(
  String title,
  String selected,
  Function(String) onSelect,
  IconData icon,
  BuildContext context, // ✅ Pass context as a parameter
) {
  bool isSelected = selected == title;

  return GestureDetector(
    onTap: () => onSelect(title),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey[200], // ✅ Corrected context usage
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: isSelected ? Colors.white : Colors.black54),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTopImages(double screenWidth) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildCircleImage(
        'assets/images/food4.jpeg',
      ),
      _buildCircleImage(
        'assets/images/food2.jpg',
      ),
      _buildCircleImage(
        'assets/images/food3.jpg',
      ),
    ],
  );
}

Widget _buildCircleImage(String imagePath) {
  return ClipOval(
    child: Image.asset(imagePath, width: 120, height: 110, fit: BoxFit.cover),
  );
}
