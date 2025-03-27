import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/Authantication/Authuser.dart';

class UnwantedProductsPage extends StatefulWidget {
  final List<String> selectedUnwantedProducts;

  UnwantedProductsPage({required this.selectedUnwantedProducts});

  @override
  _UnwantedProductsPageState createState() => _UnwantedProductsPageState();
}

class _UnwantedProductsPageState extends State<UnwantedProductsPage> {
  List<Map<String, dynamic>> unwantedProducts = [];
  List<String> selectedUnwantedProducts = [];

  @override
  void initState() {
    super.initState();
    selectedUnwantedProducts = widget.selectedUnwantedProducts;
    fetchUnwantedProducts();
  }

  Future<void> fetchUnwantedProducts() async {
    try {

      final response = await ApiHelper().httpGet('unwantedproduct/index.php');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            unwantedProducts = List<Map<String, dynamic>>.from(data['data']).map((product) {
              return {
                ...product,
                'isSelected': selectedUnwantedProducts.contains(product['unwantedproduct_name']),
              };
            }).toList();
          });
        } else {
          print("API returned error: ${data['status']}");
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching unwanted products: $e");
    }
  }

  void toggleSelection(String productName) {
    setState(() {
      for (var product in unwantedProducts) {
        if (product['unwantedproduct_name'] == productName) {
          product['isSelected'] = !product['isSelected'];
        }
      }

      if (selectedUnwantedProducts.contains(productName)) {
        selectedUnwantedProducts.remove(productName);
      } else {
        selectedUnwantedProducts.add(productName);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedUnwantedProducts.clear();
      unwantedProducts = unwantedProducts.map((product) {
        return {
          ...product,
          'isSelected': false,
        };
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All selections cleared!'),
        backgroundColor: Colors.red.shade400,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void submitSelectedData() {
    Navigator.pop(context, selectedUnwantedProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unwanted Products"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: clearSelection,
            tooltip: "Clear Selection",
          ),
        ],
      ),

      body: unwantedProducts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Wrap unwanted products inside SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: unwantedProducts.map((product) {
                  String productName = product['unwantedproduct_name'];
                  bool isSelected = selectedUnwantedProducts.contains(productName);

                  return GestureDetector(
                    onTap: () => toggleSelection(productName),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade900 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue.shade700 : Colors.grey[400]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block,
                            color: isSelected ? Colors.white : Colors.black54,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            productName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: isSelected ? Colors.white : Colors.black54)
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ➤ Selected Products Display (Already using SingleChildScrollView)
          // if (selectedUnwantedProducts.isNotEmpty)
          //   Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.all(10),
          //     color: Colors.blue.shade100,
          //     child: SingleChildScrollView(
          //       scrollDirection: Axis.horizontal,
          //       child: Row(
          //         children: selectedUnwantedProducts.map((product) {
          //           return Container(
          //             margin: EdgeInsets.symmetric(horizontal: 5),
          //             padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          //             decoration: BoxDecoration(
          //               color: Colors.blue.shade900,
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //             child: Row(
          //               children: [
          //                 Icon(Icons.check_circle, color: Colors.white, size: 16),
          //                 SizedBox(width: 5),
          //                 Text(
          //                   product,
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //                 SizedBox(width: 5),
          //                 GestureDetector(
          //                   onTap: () => toggleSelection(product),
          //                   child: Icon(Icons.close, color: Colors.white, size: 16),
          //                 ),
          //               ],
          //             ),
          //           );
          //         }).toList(),
          //       ),
          //     ),
          //   ),
        ],
      ),


      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures minimal space usage
          children: [
            // ➤ Selected Unwanted Products Display
            if (selectedUnwantedProducts.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: selectedUnwantedProducts.map((product) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text(
                              product,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => toggleSelection(product),
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            SizedBox(height: 10), // Space between selected list and button

            // ➤ Confirm Selection Button
            Container(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: submitSelectedData,
                child: Text("Confirm Selection"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
