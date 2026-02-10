import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

// แอปหลัก
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ProductList()); // กำหนดหน้าแรกเป็น ProductList
  }
}

// สร้าง Widget สำหรับรายการสินค้า
class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List products = []; // เก็บข้อมูลสินค้าทั้งหมด
  List filteredProducts = []; // เก็บข้อมูลสินค้าที่ค้นหา
  TextEditingController searchController = TextEditingController(); // ตัวควบคุมช่องค้นหา

  @override
  void initState() {
    super.initState();
    fetchProducts(); // เรียก API เมื่อโหลดหน้าครั้งแรก
  }

  // ฟังก์ชันดึงข้อมูลสินค้าจาก API
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/flutter_product_image/php_api/show_data.php'),
      );
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body); // แปลง JSON เป็น List
          filteredProducts = products; // เริ่มต้นให้แสดงสินค้าทั้งหมด
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  // ฟังก์ชันกรองสินค้าจากการค้นหา
  void filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()); // ค้นหาจากชื่อสินค้า
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')), // แถบหัวข้อ
      body: Column(
        children: [
          // ช่องค้นหาสินค้า
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by product name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterProducts, // เรียก filterProducts เมื่อพิมพ์
            ),
          ),
          // แสดงรายการสินค้า
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: CircularProgressIndicator()) // โหลดข้อมูล
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      String imageAsset =
                          'assets/images/${product['image'] ?? 'default.png'}';
                      return Card(
                        child: ListTile(
                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error); // กรณีโหลดภาพไม่ได้
                              },
                            ),
                          ),
                          title: Text(product['name'] ?? 'No Name'), // ชื่อสินค้า
                          subtitle: Text(
                            product['description'] ?? 'No Description', // รายละเอียดสินค้า
                          ),
                          trailing: Text('฿${product['price'] ?? '0.00'}'), // ราคา
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetail(product: product),
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
    );
  }
}

// หน้ารายละเอียดสินค้า
class ProductDetail extends StatelessWidget {
  final dynamic product;
  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String imageAsset = 'assets/images/${product['image'] ?? 'default.png'}';

    return Scaffold(
      appBar: AppBar(title: Text(product['name'] ?? 'Product Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงภาพสินค้า
            Center(
              child: Image.asset(
                imageAsset,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
            const SizedBox(height: 20),
            // ชื่อสินค้า
            Text('Name: ${product['name'] ?? 'No Name'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // รายละเอียดสินค้า
            Text('Description: ${product['description'] ?? 'No Description'}'),
            const SizedBox(height: 10),
            // ราคา
            Text('Price: ฿${product['price'] ?? '0.00'}'),
          ],
        ),
      ),
    );
  }
}


