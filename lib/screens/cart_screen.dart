import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _navigateToProductDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 56.sp,
                  color: Theme.of(context).hintColor,
                ),
                SizedBox(height: 12.h),
                CustomText(
                  text: 'Your cart is empty',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6.h),
                CustomText(
                  text: 'Start shopping to add items',
                  fontSize: 12.sp,
                  color: Theme.of(context).hintColor,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: CustomText(
                    text: 'Start Shopping',
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Cart Summary
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              margin: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 6.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: '${cart.totalQuantity} items',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  CustomText(
                    text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            
            // Cart Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final product = cart.items[index];
                  return GestureDetector(
                    onTap: () {
                      _navigateToProductDetail(product.id);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.r),
                            child: Image.network(
                              product.thumbnail,
                              height: 40.h,
                              width: 40.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image,
                                size: 22.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          
                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: product.title,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    CustomText(
                                      text: '\$${product.price.toStringAsFixed(2)}',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    if (product.discountPercentage > 0) ...[
                                      SizedBox(width: 4.w),
                                      CustomText(
                                        text: '-${product.discountPercentage.toStringAsFixed(0)}%',
                                        fontSize: 9.sp,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Quantity Controls
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  cart.updateQuantity(product.id, product.quantity - 1);
                                },
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 20.sp,
                                  color: product.quantity > 1 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.red,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              CustomText(
                                text: '${product.quantity}',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(width: 6.w),
                              InkWell(
                                onTap: () {
                                  cart.updateQuantity(product.id, product.quantity + 1);
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  size: 20.sp,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Checkout Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Total',
                          fontSize: 10.sp,
                          color: Theme.of(context).hintColor,
                        ),
                        CustomText(
                          text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Clear cart after checkout (optional)
                        // cart.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: CustomText(
                              text: 'Checkout successful!',
                              fontSize: 13.sp,
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: CustomText(
                        text: 'Checkout',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}