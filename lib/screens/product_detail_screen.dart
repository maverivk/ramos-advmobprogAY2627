import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart'; // Add this import
import '../models/product.dart';
import '../services/product_service.dart';
import '../providers/cart_provider.dart'; // Add this
import '../widgets/custom_text.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService().getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Product Details',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, size: 24.sp),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CustomText(
                    text: 'Added to favorites!',
                    fontSize: 14.sp,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, size: 24.sp),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CustomText(
                    text: 'Share feature coming soon!',
                    fontSize: 14.sp,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Error loading product',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: snapshot.error.toString(),
                    fontSize: 14.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            );
          }

          final product = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: _buildProductDetail(product),
              ),
              _buildBottomBar(product),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductDetail(Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Images Carousel
          Container(
            height: 300.h,
            width: double.infinity,
            color: Theme.of(context).cardColor,
            child: PageView.builder(
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  product.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image,
                    size: 64.sp,
                    color: Theme.of(context).hintColor,
                  ),
                );
              },
            ),
          ),
          
          // Product Info
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Brand
                CustomText(
                  text: product.title,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: product.brand,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 8.h),
                
                // Rating & Stock
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: product.rating.toStringAsFixed(1),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            text: ' (${product.reviews.length} reviews)',
                            fontSize: 12.sp,
                            color: Theme.of(context).hintColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: product.stock > 0 
                            ? Colors.green.withOpacity(0.2) 
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: CustomText(
                        text: product.stock > 0 
                            ? 'In Stock (${product.stock})' 
                            : 'Out of Stock',
                        fontSize: 12.sp,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Price Section
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Price',
                            fontSize: 12.sp,
                            color: Theme.of(context).hintColor,
                          ),
                          Row(
                            children: [
                              CustomText(
                                text: '\$${product.price.toStringAsFixed(2)}',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              if (product.discountPercentage > 0) ...[
                                SizedBox(width: 8.w),
                                CustomText(
                                  text: '\$${(product.price / (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                                  fontSize: 16.sp,
                                  color: Theme.of(context).hintColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                SizedBox(width: 8.w),
                                Container(
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
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Description
                CustomText(
                  text: 'Description',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: product.description,
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                  height: 1.5,
                ),
                SizedBox(height: 16.h),
                
                // Product Details
                CustomText(
                  text: 'Product Details',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(context, 'Category', product.category),
                      _buildDetailRow(context, 'SKU', product.sku),
                      _buildDetailRow(context, 'Weight', '${product.weight} kg'),
                      _buildDetailRow(context, 'Dimensions', '${product.dimensions.width} x ${product.dimensions.height} x ${product.dimensions.depth} cm'),
                      _buildDetailRow(context, 'Warranty', product.warrantyInformation),
                      _buildDetailRow(context, 'Shipping', product.shippingInformation),
                      _buildDetailRow(context, 'Return Policy', product.returnPolicy),
                      _buildDetailRow(context, 'Minimum Order', '${product.minimumOrderQuantity} units'),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Tags
                if (product.tags.isNotEmpty) ...[
                  CustomText(
                    text: 'Tags',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: product.tags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: CustomText(
                          text: tag,
                          fontSize: 12.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                ],
                
                // Reviews
                if (product.reviews.isNotEmpty) ...[
                  CustomText(
                    text: 'Reviews',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 8.h),
                  ...product.reviews.map((review) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < review.rating ? Icons.star : Icons.star_border,
                                  size: 16.sp,
                                  color: Colors.amber,
                                );
                              }),
                              SizedBox(width: 8.w),
                              CustomText(
                                text: review.reviewerName,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              const Spacer(),
                              CustomText(
                                text: review.date,
                                fontSize: 12.sp,
                                color: Theme.of(context).hintColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: review.comment,
                            fontSize: 14.sp,
                            color: Theme.of(context).hintColor,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '$label:',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Bar with Quantity Controls and Add to Cart
  Widget _buildBottomBar(Product product) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final isInCart = cart.items.any((item) => item.id == product.id);
        final existingItem = cart.items.firstWhere(
          (item) => item.id == product.id,
          orElse: () => CartProduct(
            id: product.id,
            title: product.title,
            price: product.price,
            quantity: 0,
            total: 0,
            discountPercentage: product.discountPercentage,
            discountedTotal: 0,
            thumbnail: product.thumbnail,
          ),
        );
        final currentQuantity = isInCart ? existingItem.quantity : 0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 20.sp),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    CustomText(
                      text: '$_quantity',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 20.sp),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isInCart) {
                      // Update quantity if already in cart
                      cart.updateQuantity(product.id, currentQuantity + _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(
                            text: 'Cart updated! 🛒',
                            fontSize: 13.sp,
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      // Add new item to cart
                      cart.addToCart(product, quantity: _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(
                            text: 'Added to cart! 🛒',
                            fontSize: 13.sp,
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                    // Reset quantity to 1 after adding
                    setState(() => _quantity = 1);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: isInCart ? Colors.green : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: CustomText(
                    text: isInCart 
                        ? 'Update Cart (${currentQuantity + _quantity})' 
                        : 'Add to Cart',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}