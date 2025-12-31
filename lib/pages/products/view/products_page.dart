// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:core_dashboard/pages/products/data/model/product_model.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_cubit.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_state.dart';
import 'package:core_dashboard/pages/products/view/widgets/add_product.dart';
import 'package:core_dashboard/pages/products/view/widgets/delete_product.dart';
import 'package:core_dashboard/pages/products/view/widgets/update_product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    context.read<ProductCubit>().fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Products Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                final cubit = context.read<ProductCubit>();

                showDialog(
                  context: context,
                  builder: (context) => BlocProvider.value(
                      value: cubit, child: const AddProductDialog()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5542F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل البحث والفلترة
            Row(
              children: [
                // حقل البحث
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF6B7280)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // فلتر الفئة
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'All',
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['All', 'Men', 'Women', 'Kids', 'Shoes']
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // جدول المنتجات
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // رأس الجدول
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          // صورة المنتج
                          SizedBox(
                            width: 50,
                            child: Text(
                              'Image',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // اسم المنتج
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          // الوصف
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          // الفئة
                          Expanded(
                            child: Text(
                              'Category',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          // السعر
                          Expanded(
                            child: Text(
                              'Price',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          // المخزون
                          Expanded(
                            child: Text(
                              'Stock',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          // التقييم
                          Expanded(
                            child: Text(
                              'Rating',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          // الإجراءات
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Actions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    // محتوى الجدول (بيانات وهمية للعرض)
                    // ... داخل الـ Column في ProductsPage
                    Expanded(
                      child: BlocBuilder<ProductCubit, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoading) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF5542F6)));
                          }

                          if (state is ProductError) {
                            return Center(
                                child: Text('Error: ${state.message}',
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444))));
                          }

                          if (state is ProductLoaded) {
                            final products = state.products;

                            if (products.isEmpty) {
                              return SingleChildScrollView(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24, horizontal: 32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF3F4F6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            size: 36,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No products found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add products to see them here.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductRow(
                                  id: product.id,
                                  imageUrl: product.imageUrl ?? '',
                                  name: product.name,
                                  description: product.description,
                                  category: product.category ?? '',
                                  price: product.price ?? 0.0, // ✅ قيمة افتراضية
                                  stock: product.stock ?? 0,
                                  rating: product.rating ?? 0.0,
                                  stockStatus: product.stockStatus,
                                );
                              },
                            );
                          }

                          // حالة احتياطية في حال لم يتحقق أي شرط
                          return const Center(child: Text("Please wait..."));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// صف المنتج في الجدول
class ProductRow extends StatelessWidget {
  final String? id;
  final String imageUrl;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final double rating;
  final String? stockStatus; // ✅ إضافة stockStatus

  const ProductRow({
    super.key,
    this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.rating,
    this.stockStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // صورة المنتج
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF3F4F6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF9CA3AF),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // اسم المنتج
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // الوصف
          Expanded(
            flex: 2,
            child: Text(
              description,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),

          // الفئة
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5542F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // السعر
          Expanded(
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // المخزون
          Expanded(
            child: _buildStockBadge(stock),
          ),

          // التقييم
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // الأزرار
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final cubit = context.read<ProductCubit>();

                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: UpdateProductDialog(
                          product: ProductModel(
                            id: id,
                            name: name,
                            description: description,
                            price: price,
                            category: category,
                            stock: stock,
                            rating: rating,
                            imageUrl: imageUrl,
                            stockStatus: stockStatus, // ✅ تمرير stockStatus
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF5542F6),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    final cubit = context.read<ProductCubit>();

                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: DeleteProductDialog(
                            product: ProductModel(
                                id: id, name: name, description: description)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFEF4444),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء badge المخزون بناءً على الكمية
  Widget _buildStockBadge(int stock) {
    Color bgColor;
    Color textColor;
    String text;

    if (stock > 10) {
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF059669);
      text = 'In Stock ($stock)';
    } else if (stock > 0) {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
      text = 'Low Stock ($stock)';
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      text = 'Out of Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
