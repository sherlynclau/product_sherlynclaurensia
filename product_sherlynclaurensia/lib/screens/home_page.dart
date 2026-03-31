import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Product> _allProducts = [];
  bool isLoading = true;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final apiService = ApiService();
      final List<Map<String, dynamic>> allProductsData = await apiService
          .getAllProducts();

      setState(() {
        _allProducts = allProductsData.map((e) => Product.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allProducts = [];
        isLoading = false;
      });
      // error handling could be done with snackbar or dialog if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'All'
        ? _allProducts
        : _allProducts.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                selectedCategory = selectedCategory == 'All'
                    ? 'electronics'
                    : 'All';
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  _buildProductsList('All Products', filteredProducts),
                ],
              ),
            ),
    );
  }

  Widget _buildProductsList(String title, List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(8.0)),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            final Product product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.getShortTitle(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              color: product.isExpensive
                                  ? Colors.red
                                  : Colors.black,
                              fontWeight: product.isExpensive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.rate.toStringAsFixed(1)} (${product.rating.count})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// 1. Jelaskan alur data dari ApiService hingga tampil di ListView.
// Alur data dimulai dari class HomePage yang memanggil ApiService untuk mengambil data data produk. 
// Lalu ApiService akan mengembalikan data dalam bentuk List<Map<String, dynamic>>. 
// Kemudian akan diubah menjadi List<Product>
// Setelah itu, List<Product> disimpan dalam state HomePage dan digunakan untuk membangun 
// ListView yang menampilkan gambar produk, kategori, judul, harga, dan rating produk satu per satu.

// 2. Mengapa kita perlu memisahkan list data asli dan list data yang ditampilkan saat melakukan filter?
// Agar bisa mengembalikan data asli tanpa perlu memanggil ulang API saat filter dihapus, 
// Serta agar kita bisa menampilkan data sesuai dengan yang diinginkan
// tanpa mengubah data asli API.
