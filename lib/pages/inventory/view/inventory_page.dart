import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  // Categories Data
  final List<CategoryData> _categories = [
    CategoryData(name: 'All', icon: Icons.apps_rounded, count: 48, color: const Color(0xFF6366F1)),
    CategoryData(name: 'Electronics', icon: Icons.devices_rounded, count: 15, color: const Color(0xFF0EA5E9)),
    CategoryData(name: 'Clothing', icon: Icons.checkroom_rounded, count: 12, color: const Color(0xFFEC4899)),
    CategoryData(name: 'Shoes', icon: Icons.directions_walk_rounded, count: 8, color: const Color(0xFFF59E0B)),
    CategoryData(name: 'Accessories', icon: Icons.watch_rounded, count: 7, color: const Color(0xFF8B5CF6)),
    CategoryData(name: 'Home & Garden', icon: Icons.home_rounded, count: 6, color: const Color(0xFF10B981)),
  ];

  // Products Data
  List<ProductStock> _products = [
    ProductStock(id: '1', name: 'iPhone 15 Pro Max', sku: 'APL-IP15PM-256', category: 'Electronics', quantity: 45, minStock: 10, price: 1199.99, status: 'in_stock'),
    ProductStock(id: '2', name: 'Samsung Galaxy S24', sku: 'SAM-GS24-128', category: 'Electronics', quantity: 8, minStock: 15, price: 899.99, status: 'low_stock'),
    ProductStock(id: '3', name: 'Nike Air Max 270', sku: 'NK-AM270-BLK', category: 'Shoes', quantity: 0, minStock: 5, price: 150.00, status: 'out_of_stock'),
    ProductStock(id: '4', name: 'Levi\'s 501 Jeans', sku: 'LV-501-32-BLU', category: 'Clothing', quantity: 25, minStock: 10, price: 79.99, status: 'in_stock'),
    ProductStock(id: '5', name: 'Apple Watch Series 9', sku: 'APL-AWS9-45', category: 'Accessories', quantity: 12, minStock: 8, price: 399.99, status: 'in_stock'),
    ProductStock(id: '6', name: 'Sony WH-1000XM5', sku: 'SNY-WH1KXM5', category: 'Electronics', quantity: 3, minStock: 5, price: 349.99, status: 'low_stock'),
  ];

  // Movements Data
  List<StockMovement> _movements = [
    StockMovement(date: '2024-01-15', time: '14:30', product: 'iPhone 15 Pro Max', type: 'in', quantity: 20, before: 25, after: 45, reason: 'New shipment arrived'),
    StockMovement(date: '2024-01-15', time: '11:20', product: 'Samsung Galaxy S24', type: 'out', quantity: 5, before: 13, after: 8, reason: 'Customer order #1234'),
    StockMovement(date: '2024-01-14', time: '16:45', product: 'Nike Air Max 270', type: 'out', quantity: 3, before: 3, after: 0, reason: 'Customer order #1230'),
    StockMovement(date: '2024-01-14', time: '09:15', product: 'Apple Watch Series 9', type: 'adjustment', quantity: 2, before: 10, after: 12, reason: 'Inventory audit correction'),
  ];

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

  List<ProductStock> get _filteredProducts {
    return _products.where((p) {
      final matchCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchStatus = _selectedStatus == 'All' ||
          p.status == _selectedStatus.toLowerCase().replaceAll(' ', '_');
      final matchSearch = _searchController.text.isEmpty ||
          p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchCategory && matchStatus && matchSearch;
    }).toList();
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

  // ══════════════════════════════════════════════════════════════════════════════
  // Categories Sidebar
  // ══════════════════════════════════════════════════════════════════════════════
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

          // Categories List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedCategory = category.name),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? category.color
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category.color
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                category.icon,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? category.color
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category.color
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${category.count}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Stats
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildQuickStat('Total Items', '48', Icons.inventory_2_rounded,
                    const Color(0xFF6366F1)),
                const SizedBox(height: 12),
                _buildQuickStat('Low Stock', '5', Icons.warning_rounded,
                    const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                _buildQuickStat('Out of Stock', '3', Icons.error_rounded,
                    const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
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

  // Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          // Back Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/entry-point');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color(0xFF64748B),
              tooltip: 'Back',
            ),
          ),
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
          _buildActionButton(Icons.refresh_rounded, 'Refresh', null),
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

  // ══════════════════════════════════════════════════════════════════════════════
  // Stats Cards
  // ══════════════════════════════════════════════════════════════════════════════
  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard(
                  'Total Products',
                  '48',
                  Icons.inventory_2_rounded,
                  const Color(0xFF6366F1),
                  '+5 this week')),
          const SizedBox(width: 16),
          Expanded(
              child: _buildStatCard(
                  'In Stock',
                  '40',
                  Icons.check_circle_rounded,
                  const Color(0xFF10B981),
                  '83% available')),
          const SizedBox(width: 16),
          Expanded(
              child: _buildStatCard('Low Stock', '5', Icons.warning_rounded,
                  const Color(0xFFF59E0B), 'Needs reorder')),
          const SizedBox(width: 16),
          Expanded(
              child: _buildStatCard('Out of Stock', '3', Icons.error_rounded,
                  const Color(0xFFEF4444), 'Action needed')),
          const SizedBox(width: 16),
          Expanded(
              child: _buildStatCard(
                  'Total Value',
                  '\$156,420',
                  Icons.attach_money_rounded,
                  const Color(0xFF0EA5E9),
                  '+12.5% growth')),
        ],
      ),
    );
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

  // ══════════════════════════════════════════════════════════════════════════════
  // Tab Bar
  // ══════════════════════════════════════════════════════════════════════════════
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

  // ══════════════════════════════════════════════════════════════════════════════
  // Stock Levels Tab
  // ══════════════════════════════════════════════════════════════════════════════
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

          // Products List
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) =>
                        _buildProductRow(_filteredProducts[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(ProductStock product) {
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
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        color: Color(0xFF94A3B8), size: 22),
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
            // SKU
            Expanded(
              flex: 2,
              child: Text(product.sku,
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
                  product.category,
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
                '${product.quantity}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: product.status == 'out_of_stock'
                      ? const Color(0xFFEF4444)
                      : product.status == 'low_stock'
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF1E293B),
                ),
              ),
            ),
            // Min Stock
            Expanded(
                flex: 1,
                child: Text('${product.minStock}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13))),
            // Status
            Expanded(flex: 2, child: _buildStatusBadge(product.status)),
            // Value
            Expanded(
              flex: 2,
              child: Text(
                '\$${(product.quantity * product.price).toStringAsFixed(2)}',
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
                    onPressed: () => _showUpdateDialog(product),
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    color: const Color(0xFF6366F1),
                    tooltip: 'Edit',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
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
    ProductStock? selectedProduct;
    _quantityController.clear();
    _reasonController.clear();
    _notesController.clear();

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

                  // Product Selection
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
                      child: DropdownButton<ProductStock>(
                        value: selectedProduct,
                        hint: const Text('Choose a product...'),
                        isExpanded: true,
                        items: _products
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      Text(p.name),
                                      const Spacer(),
                                      Text('(${p.quantity} in stock)',
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
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
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
              onPressed: () {
                if (selectedProduct != null &&
                    _quantityController.text.isNotEmpty) {
                  final qty = int.tryParse(_quantityController.text) ?? 0;
                  if (qty > 0) {
                    // Add movement to list
                    setState(() {
                      int newQty;
                      if (selectedMovementType == 'in') {
                        newQty = selectedProduct!.quantity + qty;
                      } else if (selectedMovementType == 'out') {
                        newQty =
                            (selectedProduct!.quantity - qty).clamp(0, 999999);
                      } else {
                        newQty = qty;
                      }

                      _movements.insert(
                          0,
                          StockMovement(
                            date: DateTime.now().toString().substring(0, 10),
                            time:
                                '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            product: selectedProduct!.name,
                            type: selectedMovementType,
                            quantity: qty,
                            before: selectedProduct!.quantity,
                            after: newQty,
                            reason: _reasonController.text.isNotEmpty
                                ? _reasonController.text
                                : 'Manual update',
                          ));

                      // Update product quantity
                      final index = _products
                          .indexWhere((p) => p.id == selectedProduct!.id);
                      if (index != -1) {
                        final p = _products[index];
                        String newStatus;
                        if (newQty <= 0) {
                          newStatus = 'out_of_stock';
                        } else if (newQty <= p.minStock) {
                          newStatus = 'low_stock';
                        } else {
                          newStatus = 'in_stock';
                        }
                        _products[index] = ProductStock(
                          id: p.id,
                          name: p.name,
                          sku: p.sku,
                          category: p.category,
                          quantity: newQty,
                          minStock: p.minStock,
                          price: p.price,
                          status: newStatus,
                        );
                      }
                    });
                    Navigator.pop(ctx);
                    _showSuccessSnackBar('Stock movement added successfully');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Add Movement'),
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

  void _showProductDetails(ProductStock product) {
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
                  color: product.status == 'in_stock'
                      ? const Color(0xFFD1FAE5)
                      : product.status == 'low_stock'
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      product.status == 'in_stock'
                          ? Icons.check_circle_rounded
                          : product.status == 'low_stock'
                              ? Icons.warning_rounded
                              : Icons.error_rounded,
                      color: product.status == 'in_stock'
                          ? const Color(0xFF059669)
                          : product.status == 'low_stock'
                              ? const Color(0xFFD97706)
                              : const Color(0xFFDC2626),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.status == 'in_stock'
                          ? 'In Stock'
                          : product.status == 'low_stock'
                              ? 'Low Stock - Reorder Soon'
                              : 'Out of Stock - Action Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: product.status == 'in_stock'
                            ? const Color(0xFF059669)
                            : product.status == 'low_stock'
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
                    _buildDetailRow(Icons.qr_code_rounded, 'SKU', product.sku),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(
                        Icons.category_rounded, 'Category', product.category),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.inventory_rounded, 'Current Stock',
                        '${product.quantity} units'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.warning_amber_rounded,
                        'Min Stock Level', '${product.minStock} units'),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow(Icons.attach_money_rounded, 'Unit Price',
                        '\$${product.price.toStringAsFixed(2)}'),
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
                      '\$${(product.quantity * product.price).toStringAsFixed(2)}',
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showUpdateDialog(product);
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Stock'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
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

// ══════════════════════════════════════════════════════════════════════════════════
// Data Models
// ══════════════════════════════════════════════════════════════════════════════════
class CategoryData {
  final String name;
  final IconData icon;
  final int count;
  final Color color;

  CategoryData(
      {required this.name,
      required this.icon,
      required this.count,
      required this.color});
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
