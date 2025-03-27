import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/Authantication/Authuser.dart';

class DesiredProductsPage extends StatefulWidget {
  final List<String> selectedProducts;

  DesiredProductsPage({required this.selectedProducts});

  @override
  _DesiredProductsPageState createState() => _DesiredProductsPageState();
}

class _DesiredProductsPageState extends State<DesiredProductsPage> {
  List<Map<String, dynamic>> products = [];
  List<String> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    selectedProducts = List.from(widget.selectedProducts);
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {

      final response = await ApiHelper().httpGet('desiredproduct/index.php');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            products = List<Map<String, dynamic>>.from(data['data']).map((product) {
              return {
                ...product,
                'isSelected': selectedProducts.contains(product['desiredproduct_name']),
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
      print("Error fetching products: $e");
    }
  }

  void toggleSelection(String productName) {
    setState(() {
      for (var product in products) {
        if (product['desiredproduct_name'] == productName) {
          product['isSelected'] = !product['isSelected'];
        }
      }

      if (selectedProducts.contains(productName)) {
        selectedProducts.remove(productName);
      } else {
        selectedProducts.add(productName);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedProducts.clear();
      products = products.map((product) {
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

  void submitSelection() {
    Navigator.pop(context, selectedProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Desired Products"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: clearSelection,
            tooltip: "Clear Selection",
          ),
        ],
      ),

        body: products.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: products.map((product) {
                    String productName = product['desiredproduct_name'];
                    bool isSelected = product['isSelected'] ?? false;

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
                              Icons.shopping_basket,
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

              // ➤ Selected Products Display
              // if (selectedProducts.isNotEmpty)
              //   Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.all(10),
              //     color: Colors.green.shade100,
              //     child: SingleChildScrollView(
              //       scrollDirection: Axis.horizontal,
              //       child: Row(
              //         children: selectedProducts.map((product) {
              //           return Container(
              //             margin: EdgeInsets.symmetric(horizontal: 5),
              //             padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              //             decoration: BoxDecoration(
              //               color: Colors.green.shade600,
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
        ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensures the column takes minimum space
          children: [
            // ➤ Selected Products Display
            if (selectedProducts.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: selectedProducts.map((product) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
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

            SizedBox(height: 10), // Space between list and button

            // ➤ Confirm Selection Button
            Container(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: submitSelection,
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
