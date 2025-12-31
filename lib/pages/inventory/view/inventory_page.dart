import 'package:core_dashboard/pages/products/logic/cubit/product_cubit.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_state.dart';
import 'package:core_dashboard/pages/products/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_dashboard/pages/categories/logic/cubit/category_cubit.dart';
import 'package:core_dashboard/pages/categories/logic/cubit/category_state.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // ألوان للفئات
  final List<Color> _categoryColors = [
    const Color(0xFF0EA5E9),
    const Color(0xFFEC4899),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFF10B981),
    const Color(0xFFEF4444),
    const Color(0xFF14B8A6),
  ];
  final List<ProductStock> _products = [];
  final List<StockMovement> _movements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // فلترة المنتجات من Supabase
  List<ProductModel> _filterProducts(List<ProductModel> products) {
    return products.where((p) {
      // مقارنة الفئة بدون حساسية لحالة الأحرف
      final matchCategory = _selectedCategory == 'All' ||
          (p.category?.toLowerCase() == _selectedCategory.toLowerCase());
      final matchStatus = _selectedStatus == 'All' ||
          _getStockStatus(p.stock ?? 0) ==
              _selectedStatus.toLowerCase().replaceAll(' ', '_');
      final matchSearch = _searchController.text.isEmpty ||
          p.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchCategory && matchStatus && matchSearch;
    }).toList();
  }

  // تحديد حالة المخزون
  String _getStockStatus(int stock) {
    if (stock <= 0) return 'out_of_stock';
    if (stock <= 10) return 'low_stock';
    return 'in_stock';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // Categories Sidebar
          _buildCategoriesSidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                _buildStatsCards(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStockLevelsTab(),
                      _buildMovementsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.category_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Filter by category',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Categories List - من Supabase
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  );
                }

                if (state is CategoryError) {
                  return SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Error loading',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<CategoryCubit>().fetchCategories();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is CategoryLoaded) {
                  final categories = state.categories;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedCategory == 'All';
                        return _buildCategoryItem(
                          name: 'All',
                          color: const Color(0xFF6366F1),
                          isSelected: isSelected,
                          onTap: () =>
                              setState(() => _selectedCategory = 'All'),
                        );
                      }

                      final category = categories[index - 1];
                      final color =
                          _categoryColors[(index - 1) % _categoryColors.length];
                      final isSelected = _selectedCategory == category.name;

                      return _buildCategoryItem(
                        name: category.name,
                        color: color,
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => _selectedCategory = category.name),
                      );
                    },
                  );
                }

                return const Center(child: Text('Loading...'));
              },
            ),
          ),

          // Quick Stats - من Supabase
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              int total = 0;
              int inStock = 0;
              int lowStock = 0;
              int outOfStock = 0;

              if (state is ProductLoaded) {
                final products = state.products;
                total = products.length;
                inStock = products
                    .where((p) => _getStockStatus(p.stock ?? 0) == 'in_stock')
                    .length;
                lowStock = products
                    .where((p) => _getStockStatus(p.stock ?? 0) == 'low_stock')
                    .length;
                outOfStock = products
                    .where(
                        (p) => _getStockStatus(p.stock ?? 0) == 'out_of_stock')
                    .length;
              }

              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Total Items - قابل للنقر
                    _buildClickableStatCard(
                      label: 'Total Items',
                      value: '$total',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFF6366F1),
                      isSelected: _selectedStatus == 'All',
                      onTap: () => setState(() => _selectedStatus = 'All'),
                    ),
                    const SizedBox(height: 8),
                    // In Stock
                    _buildClickableStatCard(
                      label: 'In Stock',
                      value: '$inStock',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      isSelected: _selectedStatus == 'In Stock',
                      onTap: () => setState(() => _selectedStatus = 'In Stock'),
                    ),
                    const SizedBox(height: 8),
                    // Low Stock
                    _buildClickableStatCard(
                      label: 'Low Stock',
                      value: '$lowStock',
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFF59E0B),
                      isSelected: _selectedStatus == 'Low Stock',
                      onTap: () =>
                          setState(() => _selectedStatus = 'Low Stock'),
                    ),
                    const SizedBox(height: 8),
                    // Out of Stock
                    _buildClickableStatCard(
                      label: 'Out of Stock',
                      value: '$outOfStock',
                      icon: Icons.error_rounded,
                      color: const Color(0xFFEF4444),
                      isSelected: _selectedStatus == 'Out of Stock',
                      onTap: () =>
                          setState(() => _selectedStatus = 'Out of Stock'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Category Item Widget
  Widget _buildCategoryItem({
    required String name,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    name == 'All' ? Icons.apps_rounded : Icons.category_rounded,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? color : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Clickable Stat Card - بطاقة إحصائية قابلة للنقر
  Widget _buildClickableStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // الأيقونة
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(width: 10),
              // النص
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : const Color(0xFF64748B),
                  ),
                ),
              ),
              // القيمة
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          // Back Button

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Inventory Management',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor stock levels, manage inventory, and track product movements',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildActionButton(Icons.file_download_outlined, 'Export', null),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddStockDialog(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Stock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback? onTap) {
    return OutlinedButton.icon(
      onPressed: onTap ?? () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF64748B),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatsCards() {
    // نستخدم BlocBuilder للحصول على البيانات الحقيقية من Supabase
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        // القيم الافتراضية
        int total = 0;
        int inStock = 0;
        int lowStock = 0;
        int outOfStock = 0;
        double totalValue = 0.0;

        // إذا تم تحميل البيانات بنجاح
        if (state is ProductLoaded) {
          final products = state.products;

          // 1. Total Products = عدد كل المنتجات
          total = products.length;

          // 2. حساب كل حالة
          for (var product in products) {
            final stock = product.stock ?? 0;
            final price = product.price ?? 0.0;

            // حساب القيمة الإجمالية = الكمية × السعر
            totalValue += stock * price;

            // تصنيف المنتج حسب المخزون
            final status = _getStockStatus(stock);
            if (status == 'in_stock') {
              inStock++;
            } else if (status == 'low_stock') {
              lowStock++;
            } else {
              outOfStock++;
            }
          }
        }

        // حساب النسبة المئوية للمنتجات المتوفرة
        final availablePercent =
            total > 0 ? ((inStock / total) * 100).toStringAsFixed(0) : '0';

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              // 1. Total Products - إجمالي المنتجات
              Expanded(
                child: _buildStatCard(
                  'Total Products',
                  '$total',
                  Icons.inventory_2_rounded,
                  const Color(0xFF6366F1),
                  'All inventory items',
                ),
              ),
              const SizedBox(width: 16),

              // 2. In Stock - المنتجات المتوفرة (stock > 10)
              Expanded(
                child: _buildStatCard(
                  'In Stock',
                  '$inStock',
                  Icons.check_circle_rounded,
                  const Color(0xFF10B981),
                  '$availablePercent% available',
                ),
              ),
              const SizedBox(width: 16),

              // 3. Low Stock - مخزون منخفض (stock <= 10 && stock > 0)
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  '$lowStock',
                  Icons.warning_rounded,
                  const Color(0xFFF59E0B),
                  lowStock > 0 ? 'Needs reorder' : 'All good',
                ),
              ),
              const SizedBox(width: 16),

              // 4. Out of Stock - نفد المخزون (stock <= 0)
              Expanded(
                child: _buildStatCard(
                  'Out of Stock',
                  '$outOfStock',
                  Icons.error_rounded,
                  const Color(0xFFEF4444),
                  outOfStock > 0 ? 'Action needed' : 'None',
                ),
              ),
              const SizedBox(width: 16),

              // 5. Total Value - القيمة الإجمالية للمخزون
              Expanded(
                child: _buildStatCard(
                  'Total Value',
                  '\$${_formatNumber(totalValue)}',
                  Icons.attach_money_rounded,
                  const Color(0xFF0EA5E9),
                  'Stock value',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // تنسيق الأرقام الكبيرة (مثل 156420 → 156,420)
  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(2);
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, size: 14, color: color),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 20),
                SizedBox(width: 8),
                Text('Stock Levels'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 20),
                SizedBox(width: 8),
                Text('Stock Movements'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockLevelsTab() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search products by name or SKU...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: ['All', 'In Stock', 'Low Stock', 'Out of Stock']
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFFF8FAFC),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Product',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('SKU',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Category',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 1,
                    child: Text('Qty',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 1,
                    child: Text('Min',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Value',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                SizedBox(
                    width: 80,
                    child: Text('Actions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products List - من Supabase
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  );
                }

                if (state is ProductError) {
                  return SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text('Error: ${state.message}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<ProductCubit>().fetchProducts(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is ProductLoaded) {
                  final filteredProducts = _filterProducts(state.products);
                  if (filteredProducts.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.separated(
                    itemCount: filteredProducts.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) =>
                        _buildProductRow(filteredProducts[index]),
                  );
                }

                return const Center(child: Text('Loading products...'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(ProductModel product) {
    final stock = product.stock ?? 0;
    final status = _getStockStatus(stock);
    final price = product.price ?? 0.0;

    return InkWell(
      onTap: () => _showProductDetails(product),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Product Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      image: product.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product.imageUrl == null
                        ? const Icon(Icons.inventory_2_rounded,
                            color: Color(0xFF94A3B8), size: 22)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // ID
            Expanded(
              flex: 2,
              child: Text(product.id?.substring(0, 8) ?? '-',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontFamily: 'monospace')),
            ),
            // Category
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.category ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Quantity
            Expanded(
              flex: 1,
              child: Text(
                '$stock',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: status == 'out_of_stock'
                      ? const Color(0xFFEF4444)
                      : status == 'low_stock'
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF1E293B),
                ),
              ),
            ),
            // Min Stock
            Expanded(
                flex: 1,
                child: Text('10',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13))),
            // Status
            Expanded(flex: 2, child: _buildStatusBadge(status)),
            // Value
            Expanded(
              flex: 2,
              child: Text(
                '\$${(stock * price).toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontSize: 14),
              ),
            ),
            // Actions
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _showProductDetails(product),
                    icon: const Icon(Icons.visibility_outlined),
                    iconSize: 20,
                    color: const Color(0xFF6366F1),
                    tooltip: 'View',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'in_stock':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        label = 'In Stock';
        break;
      case 'low_stock':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        icon = Icons.warning_rounded;
        label = 'Low Stock';
        break;
      case 'out_of_stock':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.error_rounded;
        label = 'Out of Stock';
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        icon = Icons.help_outline;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No products found',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text('Try adjusting your search or filter',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // Movements Tab
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildMovementsTab() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Date & Time',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 3,
                    child: Text('Product',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 1,
                    child: Text('Change',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text('Before > After',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
                Expanded(
                    flex: 3,
                    child: Text('Reason',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                            fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _movements.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (context, index) =>
                  _buildMovementRow(_movements[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementRow(StockMovement m) {
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (m.type) {
      case 'in':
        typeColor = const Color(0xFF10B981);
        typeIcon = Icons.add_circle_rounded;
        typeLabel = 'Stock In';
        break;
      case 'out':
        typeColor = const Color(0xFFEF4444);
        typeIcon = Icons.remove_circle_rounded;
        typeLabel = 'Stock Out';
        break;
      default:
        typeColor = const Color(0xFFF59E0B);
        typeIcon = Icons.swap_horiz_rounded;
        typeLabel = 'Adjustment';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.date,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                        fontSize: 13)),
                Text(m.time,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: Text(m.product,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(typeIcon, size: 14, color: typeColor),
                  const SizedBox(width: 5),
                  Text(typeLabel,
                      style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              m.type == 'in'
                  ? '+${m.quantity}'
                  : m.type == 'out'
                      ? '-${m.quantity}'
                      : '${m.quantity}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: typeColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('${m.before}',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 13)),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 14, color: Color(0xFF94A3B8))),
                Text('${m.after}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontSize: 13)),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: Text(m.reason,
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // Dialogs
  // ══════════════════════════════════════════════════════════════════════════════
  void _showAddStockDialog() {
    String selectedMovementType = 'in';
    ProductModel? selectedProduct;
    _quantityController.clear();
    _reasonController.clear();
    _notesController.clear();

    // جلب المنتجات من ProductCubit
    final productState = context.read<ProductCubit>().state;
    List<ProductModel> products = [];
    if (productState is ProductLoaded) {
      products = productState.products;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child:
                    const Icon(Icons.add_box_rounded, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              const Text('Add Stock Movement'),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movement Type Selection
                  const Text('Movement Type',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMovementTypeButton(
                          'Stock In',
                          Icons.add_circle_rounded,
                          const Color(0xFF10B981),
                          selectedMovementType == 'in',
                          () =>
                              setDialogState(() => selectedMovementType = 'in'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMovementTypeButton(
                          'Stock Out',
                          Icons.remove_circle_rounded,
                          const Color(0xFFEF4444),
                          selectedMovementType == 'out',
                          () => setDialogState(
                              () => selectedMovementType = 'out'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMovementTypeButton(
                          'Adjustment',
                          Icons.swap_horiz_rounded,
                          const Color(0xFFF59E0B),
                          selectedMovementType == 'adjustment',
                          () => setDialogState(
                              () => selectedMovementType = 'adjustment'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product Selection - من Supabase
                  const Text('Select Product',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductModel>(
                        value: selectedProduct,
                        hint: const Text('Choose a product...'),
                        isExpanded: true,
                        items: products
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('(${p.stock ?? 0} in stock)',
                                          style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 12)),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedProduct = v),
                      ),
                    ),
                  ),

                  // عرض معلومات المنتج المحدد
                  if (selectedProduct != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_rounded,
                              color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Current Stock: ${selectedProduct!.stock ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const Spacer(),
                          _buildStatusBadge(
                              _getStockStatus(selectedProduct!.stock ?? 0)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Quantity
                  const Text('Quantity',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      hintText: selectedMovementType == 'adjustment'
                          ? 'Enter new stock quantity'
                          : 'Enter quantity to ${selectedMovementType == 'in' ? 'add' : 'remove'}',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: Icon(
                        selectedMovementType == 'in'
                            ? Icons.add_rounded
                            : selectedMovementType == 'out'
                                ? Icons.remove_rounded
                                : Icons.edit_rounded,
                        color: selectedMovementType == 'in'
                            ? const Color(0xFF10B981)
                            : selectedMovementType == 'out'
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFF59E0B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),

                  // معاينة النتيجة
                  if (selectedProduct != null &&
                      _quantityController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      final qty = int.tryParse(_quantityController.text) ?? 0;
                      final currentStock = selectedProduct!.stock ?? 0;
                      int newStock;
                      if (selectedMovementType == 'in') {
                        newStock = currentStock + qty;
                      } else if (selectedMovementType == 'out') {
                        newStock = (currentStock - qty).clamp(0, 999999);
                      } else {
                        newStock = qty;
                      }
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.preview_rounded,
                                color: Color(0xFF10B981), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'New Stock: $newStock',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),

                  // Reason
                  const Text('Reason',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _reasonController.text.isEmpty
                            ? null
                            : _reasonController.text,
                        hint: const Text('Select reason...'),
                        isExpanded: true,
                        items: [
                          'New shipment arrived',
                          'Customer order',
                          'Return from customer',
                          'Damaged goods',
                          'Inventory audit',
                          'Transfer to another location',
                          'Other',
                        ]
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setDialogState(
                            () => _reasonController.text = v ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  const Text('Notes (Optional)',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any additional notes...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedProduct != null &&
                    _quantityController.text.isNotEmpty) {
                  final qty = int.tryParse(_quantityController.text) ?? 0;
                  if (qty >= 0) {
                    // حساب المخزون الجديد
                    final currentStock = selectedProduct!.stock ?? 0;
                    int newStock;
                    if (selectedMovementType == 'in') {
                      newStock = currentStock + qty;
                    } else if (selectedMovementType == 'out') {
                      newStock = (currentStock - qty).clamp(0, 999999);
                    } else {
                      newStock = qty; // adjustment = set directly
                    }

                    // تحديث المخزون في Supabase
                    Navigator.pop(ctx);

                    // استخدام ProductCubit لتحديث المخزون
                    context.read<ProductCubit>().updateStock(
                          selectedProduct!.id!,
                          newStock,
                        );

                    // إضافة الحركة للقائمة المحلية (للعرض)
                    setState(() {
                      _movements.insert(
                        0,
                        StockMovement(
                          date: DateTime.now().toString().substring(0, 10),
                          time:
                              '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          product: selectedProduct!.name,
                          type: selectedMovementType,
                          quantity: qty,
                          before: currentStock,
                          after: newStock,
                          reason: _reasonController.text.isNotEmpty
                              ? _reasonController.text
                              : 'Manual update',
                        ),
                      );
                    });

                    _showSuccessSnackBar('Stock updated successfully!');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Update Stock'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementTypeButton(String label, IconData icon, Color color,
      bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? color : const Color(0xFF94A3B8), size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? color : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showUpdateDialog(ProductStock product) {
    final TextEditingController qtyController =
        TextEditingController(text: product.quantity.toString());
    final TextEditingController minStockController =
        TextEditingController(text: product.minStock.toString());
    final TextEditingController priceController =
        TextEditingController(text: product.price.toString());
    String updateReason = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.edit_rounded, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Update: ${product.name}',
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_rounded,
                                color: Color(0xFF64748B), size: 20),
                            const SizedBox(width: 8),
                            Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('SKU: ${product.sku}',
                                style: const TextStyle(
                                    color: Color(0xFF64748B), fontSize: 12)),
                            const Spacer(),
                            _buildStatusBadge(product.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity
                  const Text('Stock Quantity',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(qtyController.text) ?? 0;
                          if (current > 0) {
                            setDialogState(() =>
                                qtyController.text = (current - 1).toString());
                          }
                        },
                        icon: const Icon(Icons.remove_circle_rounded),
                        color: const Color(0xFFEF4444),
                      ),
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(qtyController.text) ?? 0;
                          setDialogState(() =>
                              qtyController.text = (current + 1).toString());
                        },
                        icon: const Icon(Icons.add_circle_rounded),
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Min Stock Level
                  const Text('Min Stock Level',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: minStockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Minimum stock level',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Unit Price
                  const Text('Unit Price',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Unit price',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: const Icon(Icons.attach_money_rounded,
                          color: Color(0xFF10B981)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Update Reason
                  const Text('Update Reason',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: updateReason.isEmpty ? null : updateReason,
                        hint: const Text('Select reason...'),
                        isExpanded: true,
                        items: [
                          'Stock correction',
                          'Price update',
                          'Inventory audit',
                          'System sync',
                          'Manual adjustment',
                          'Other',
                        ]
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => updateReason = v ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                final newQty =
                    int.tryParse(qtyController.text) ?? product.quantity;
                final newMinStock =
                    int.tryParse(minStockController.text) ?? product.minStock;
                final newPrice =
                    double.tryParse(priceController.text) ?? product.price;

                setState(() {
                  // Record movement if quantity changed
                  if (newQty != product.quantity) {
                    _movements.insert(
                        0,
                        StockMovement(
                          date: DateTime.now().toString().substring(0, 10),
                          time:
                              '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          product: product.name,
                          type: 'adjustment',
                          quantity: (newQty - product.quantity).abs(),
                          before: product.quantity,
                          after: newQty,
                          reason: updateReason.isNotEmpty
                              ? updateReason
                              : 'Manual update',
                        ));
                  }

                  // Update product
                  final index = _products.indexWhere((p) => p.id == product.id);
                  if (index != -1) {
                    String newStatus;
                    if (newQty <= 0) {
                      newStatus = 'out_of_stock';
                    } else if (newQty <= newMinStock) {
                      newStatus = 'low_stock';
                    } else {
                      newStatus = 'in_stock';
                    }
                    _products[index] = ProductStock(
                      id: product.id,
                      name: product.name,
                      sku: product.sku,
                      category: product.category,
                      quantity: newQty,
                      minStock: newMinStock,
                      price: newPrice,
                      status: newStatus,
                    );
                  }
                });
                Navigator.pop(ctx);
                _showSuccessSnackBar('Product updated successfully');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    final stock = product.stock ?? 0;
    final price = product.price ?? 0.0;
    final status = _getStockStatus(stock);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.inventory_2_rounded,
                  color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(product.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Badge at top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: status == 'in_stock'
                      ? const Color(0xFFD1FAE5)
                      : status == 'low_stock'
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      status == 'in_stock'
                          ? Icons.check_circle_rounded
                          : status == 'low_stock'
                              ? Icons.warning_rounded
                              : Icons.error_rounded,
                      color: status == 'in_stock'
                          ? const Color(0xFF059669)
                          : status == 'low_stock'
                              ? const Color(0xFFD97706)
                              : const Color(0xFFDC2626),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status == 'in_stock'
                          ? 'In Stock'
                          : status == 'low_stock'
                              ? 'Low Stock - Reorder Soon'
                              : 'Out of Stock - Action Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: status == 'in_stock'
                            ? const Color(0xFF059669)
                            : status == 'low_stock'
                                ? const Color(0xFFD97706)
                                : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.qr_code_rounded, 'ID',
                        product.id?.substring(0, 8) ?? '-'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.category_rounded, 'Category',
                        product.category ?? '-'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.inventory_rounded, 'Current Stock',
                        '$stock units'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.warning_amber_rounded,
                        'Min Stock Level', '10 units'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.attach_money_rounded, 'Unit Price',
                        '\$${price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total Value
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Stock Value',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '\$${(stock * price).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                fontSize: 14)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class ProductStock {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int quantity;
  final int minStock;
  final double price;
  final String status;

  ProductStock({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.minStock,
    required this.price,
    required this.status,
  });
}

class StockMovement {
  final String date;
  final String time;
  final String product;
  final String type;
  final int quantity;
  final int before;
  final int after;
  final String reason;

  StockMovement({
    required this.date,
    required this.time,
    required this.product,
    required this.type,
    required this.quantity,
    required this.before,
    required this.after,
    required this.reason,
  });
}
