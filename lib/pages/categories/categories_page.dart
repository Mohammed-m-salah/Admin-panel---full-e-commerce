import 'package:core_dashboard/pages/categories/logic/cubit/category_cubit.dart';
import 'package:core_dashboard/pages/categories/logic/cubit/category_state.dart';
import 'package:core_dashboard/pages/categories/view/widgets/add_category.dart';
import 'package:core_dashboard/pages/categories/view/widgets/delete_category.dart';
import 'package:core_dashboard/pages/categories/view/widgets/update_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان وزر الإضافة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final cubit =
                        context.read<CategoryCubit>(); // ① احصل على الـ Cubit
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit, // ② مرره للـ Dialog
                        child: const AddCategoryDialog(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
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
              ],
            ),
            const SizedBox(height: 24),

            // حقل البحث
            TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
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
            const SizedBox(height: 24),

            // جدول الفئات
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
                          Expanded(
                            child: Text(
                              'Created',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
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

                    // محتوى الجدول
                    Expanded(child: BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF5542F6),
                            ),
                          );
                        } else if (state is CategoryError) {
                          return Center(child: Text("Error: ${state.message}"));
                        } else if (state is CategoryLoaded) {
                          final categories = state.categories;
                          if (categories.isEmpty) {
                            return const Center(
                                child: Text("No categories found."));
                          }
                          return ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return CategoryRow(
                                id: category.id
                                    .toString(), // مرر المعرف من قاعدة البيانات
                                name: category.name,
                                date: category.createdAt
                                        ?.toString()
                                        .split(' ')[0] ??
                                    '',
                              );
                            },
                          );
                        }
                        return const Center(
                            child: Text("Press refresh to load categories"));
                      },
                    )),
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

// صف الفئة في الجدول
class CategoryRow extends StatelessWidget {
  final String name;
  final String date;
  final String id;

  const CategoryRow({
    super.key,
    required this.name,
    required this.date,
    required this.id, // أضف هذا
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryCubit>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // الاسم
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
                fontSize: 15,
              ),
            ),
          ),

          // التاريخ
          Expanded(
            child: Text(
              date,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
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
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: UpdateCategoryDialog(
                          name: name,
                          id: id.toString(),
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
                    final cubit = context.read<CategoryCubit>();
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: DeleteCategoryDialog(
                          id: id,
                          name: name,
                        ),
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
}
