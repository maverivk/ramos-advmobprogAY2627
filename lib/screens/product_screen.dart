import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// models
import '../models/product.dart';

// services
import '../services/product_service.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'product_detail_screen.dart';  // Add this import

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await ProductService().getAllProducts();
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
      _productsFuture = Future.value(products);
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.brand.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.sp,
                  color: Theme.of(context).hintColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.w,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          
          // Search Results Count
          if (_isSearching)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomText(
                text: '${_filteredProducts.length} results found',
                fontSize: 12.sp,
                color: Theme.of(context).hintColor,
              ),
            ),
          
          SizedBox(height: 8.h),
          
          // Products Grid
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 14.sp,
                    ),
                  );
                }

                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64.sp,
                          color: Theme.of(context).hintColor,
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: _isSearching ? 'No products found' : 'No products available',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        if (_isSearching) ...[
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Try a different search term',
                            fontSize: 14.sp,
                            color: Theme.of(context).hintColor,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Image.network(
                                    product.thumbnail,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => 
                                        Icon(Icons.image, size: 24.sp),
                                  ),
                                  // Discount Badge
                                  if (product.discountPercentage > 0)
                                    Positioned(
                                      top: 8.h,
                                      left: 8.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: CustomText(
                                          text: '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                          fontSize: 10.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  // Rating Badge
                                  Positioned(
                                    bottom: 8.h,
                                    right: 8.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 12.sp,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 4.w),
                                          CustomText(
                                            text: product.rating.toStringAsFixed(1),
                                            fontSize: 10.sp,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      CustomText(
                                        text: '\$${product.price.toStringAsFixed(2)}',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      if (product.discountPercentage > 0) ...[
                                        SizedBox(width: 8.w),
                                        CustomText(
                                          text: '\$${(product.price / (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context).hintColor,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}