import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_product_page.dart';

void main() => runApp(const MyApp());

//////////////////////////////////////////////////////////////
// ✅ CONFIG (แก้ตรงนี้ถ้าเปลี่ยนเครื่อง)
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://127.0.0.1/flutter_product_image/php_api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProductList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ PRODUCT LIST PAGE
//////////////////////////////////////////////////////////////

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List products = [];
  List filteredProducts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}show_data.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          filteredProducts = products;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),

      body: Column(
        children: [

          //////////////////////////////////////////////////////
          // 🔍 SEARCH BOX
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by product name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterProducts,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 PRODUCT LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      //////////////////////////////////////////////////////
                      // ✅ IMAGE URL (สำคัญมาก)
                      //////////////////////////////////////////////////////

                     String imageUrl =
                         "${baseUrl}images/${product['image']}";
    
                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE FROM SERVER
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(product['name'] ?? 'No Name'),

                          //////////////////////////////////////////////////
                          // 📝 DESCRIPTION
                          //////////////////////////////////////////////////

                          subtitle: Text(
                            product['description'] ?? 'No Description',
                          ),

                          //////////////////////////////////////////////////
                          // 💰 PRICE
                          //////////////////////////////////////////////////

                          trailing: Text(
                            '฿${product['price'] ?? '0.00'}',
                          ),

                          //////////////////////////////////////////////////
                          // 👉 DETAIL PAGE
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetail(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ✅ ADD BUTTON
      ////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          ).then((value) {
            fetchProducts(); // ✅ รีโหลดหลังเพิ่มสินค้า
          });
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ PRODUCT DETAIL PAGE
//////////////////////////////////////////////////////////////

class ProductDetail extends StatelessWidget {
  final dynamic product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    // ✅ IMAGE URL
    ////////////////////////////////////////////////////////////

    String imageUrl =
        "${baseUrl}images/${product['image']}";

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Detail'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////

            Text(
              product['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 DESCRIPTION
            //////////////////////////////////////////////////////

            Text(product['description'] ?? ''),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 💰 PRICE
            //////////////////////////////////////////////////////

            Text(
              'ราคา: ฿${product['price']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
