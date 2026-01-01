import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/offer_model.dart';
import '../../logic/cubit/offer_cubit.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Add Offer Dialog with Target Selection (All / Category / Product)
// ═══════════════════════════════════════════════════════════════════════════════

class AddOfferDialog extends StatefulWidget {
  final String? initialType;
  final bool withCode;
  final bool isFlashSale;

  const AddOfferDialog({
    super.key,
    this.initialType,
    this.withCode = false,
    this.isFlashSale = false,
  });

  @override
  State<AddOfferDialog> createState() => _AddOfferDialogState();
}

class _AddOfferDialogState extends State<AddOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minimumPurchaseController = TextEditingController();
  final _maximumDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();

  String _discountType = 'percentage';
  String _status = 'active';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  // Target selection
  DiscountTarget _target = DiscountTarget.all;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedProductId;
  String? _selectedProductName;

  // Data lists
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _discountType = widget.initialType!;
    }
    if (widget.isFlashSale) {
      _endDate = DateTime.now().add(const Duration(hours: 24));
      _titleController.text = 'Flash Sale - ';
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final supabase = Supabase.instance.client;

      // Load categories
      final categoriesResponse = await supabase
          .from('categories')
          .select('id, name')
          .order('name');

      // Load products
      final productsResponse = await supabase
          .from('products')
          .select('id, name, category, price, image_url')
          .order('name');

      setState(() {
        _categories = List<Map<String, dynamic>>.from(categoriesResponse);
        _products = List<Map<String, dynamic>>.from(productsResponse);
        _filteredProducts = _products;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _discountValueController.dispose();
    _minimumPurchaseController.dispose();
    _maximumDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5542F6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate target selection
      if (_target == DiscountTarget.category && _selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_target == DiscountTarget.product && _selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a product'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final offer = OfferModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text),
        minimumPurchase: _minimumPurchaseController.text.isEmpty
            ? null
            : double.tryParse(_minimumPurchaseController.text),
        maximumDiscount: _maximumDiscountController.text.isEmpty
            ? null
            : double.tryParse(_maximumDiscountController.text),
        code: _codeController.text.trim().toUpperCase(),
        startDate: _startDate,
        endDate: _endDate,
        usageLimit: _usageLimitController.text.isEmpty
            ? null
            : int.tryParse(_usageLimitController.text),
        usedCount: 0,
        status: _status,
        target: _target,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        productId: _selectedProductId,
        productName: _selectedProductName,
      );

      context.read<OfferCubit>().addOffer(offer);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Selection Section
                      _buildTargetSection(),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Title
                      _buildLabel('Offer Title'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: _buildInputDecoration(
                          'Enter offer title',
                          Icons.title,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter offer title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildLabel('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: _buildInputDecoration(
                          'Enter offer description',
                          Icons.description_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Promo Code
                      _buildLabel('Promo Code (Optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _buildInputDecoration(
                          'Enter promo code (e.g., SAVE20)',
                          Icons.confirmation_number_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Discount Type & Value Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Discount Type'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildTypeChip(
                                        'percentage', 'Percentage', Icons.percent),
                                    const SizedBox(width: 12),
                                    _buildTypeChip(
                                        'fixed', 'Fixed', Icons.attach_money),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Discount Value'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _discountValueController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(
                                    _discountType == 'percentage'
                                        ? 'e.g., 25'
                                        : 'e.g., 10.00',
                                    _discountType == 'percentage'
                                        ? Icons.percent
                                        : Icons.attach_money,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Minimum Purchase & Maximum Discount
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Minimum Purchase'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _minimumPurchaseController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(
                                    'e.g., 50.00',
                                    Icons.shopping_cart_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Maximum Discount'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _maximumDiscountController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(
                                    'e.g., 100.00',
                                    Icons.money_off_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Date Range
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Start Date'),
                                const SizedBox(height: 8),
                                _buildDatePicker(
                                  _startDate,
                                  () => _selectDate(context, true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('End Date'),
                                const SizedBox(height: 8),
                                _buildDatePicker(
                                  _endDate,
                                  () => _selectDate(context, false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Usage Limit & Status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Usage Limit (Optional)'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _usageLimitController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(
                                    'Leave empty for unlimited',
                                    Icons.repeat_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Status'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildStatusChip(
                                        'active', 'Active', const Color(0xFF10B981)),
                                    const SizedBox(width: 12),
                                    _buildStatusChip(
                                        'inactive', 'Inactive', const Color(0xFFEF4444)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF5542F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFF5542F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isFlashSale ? 'Create Flash Sale' : 'Add New Discount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Apply discount to all products, category, or specific product',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5542F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5542F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Color(0xFF5542F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Apply Discount To',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Type Selection
          Row(
            children: [
              Expanded(
                child: _buildTargetOption(
                  target: DiscountTarget.all,
                  icon: Icons.apps_rounded,
                  title: 'All Products',
                  subtitle: 'Apply to entire store',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTargetOption(
                  target: DiscountTarget.category,
                  icon: Icons.category_rounded,
                  title: 'Category',
                  subtitle: 'Select a category',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTargetOption(
                  target: DiscountTarget.product,
                  icon: Icons.inventory_2_rounded,
                  title: 'Product',
                  subtitle: 'Select a product',
                ),
              ),
            ],
          ),

          // Category Selection
          if (_target == DiscountTarget.category) ...[
            const SizedBox(height: 16),
            _buildCategorySelector(),
          ],

          // Product Selection
          if (_target == DiscountTarget.product) ...[
            const SizedBox(height: 16),
            _buildProductSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetOption({
    required DiscountTarget target,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _target == target;
    return InkWell(
      onTap: () {
        setState(() {
          _target = target;
          if (target != DiscountTarget.category) {
            _selectedCategoryId = null;
            _selectedCategoryName = null;
          }
          if (target != DiscountTarget.product) {
            _selectedProductId = null;
            _selectedProductName = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5542F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5542F6)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5542F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: _categories.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No categories available'),
                )
              : Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              _selectedCategoryId == category['id'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category['id'];
                                _selectedCategoryName = category['name'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              color: isSelected
                                  ? const Color(0xFF5542F6).withOpacity(0.1)
                                  : null,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF5542F6)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.category_outlined,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF5542F6)
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF5542F6),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        if (_selectedCategoryName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected: $_selectedCategoryName',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductSelector() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Product',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        // Search field
        TextField(
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                _filteredProducts = _products;
              } else {
                _filteredProducts = _products
                    .where((p) => (p['name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              }
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon:
                const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: _filteredProducts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No products found'),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isSelected = _selectedProductId == product['id'];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedProductId = product['id'];
                            _selectedProductName = product['name'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: isSelected
                              ? const Color(0xFF5542F6).withOpacity(0.1)
                              : null,
                          child: Row(
                            children: [
                              // Product image
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  image: product['image_url'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              product['image_url']),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: product['image_url'] == null
                                    ? const Icon(
                                        Icons.image_outlined,
                                        color: Color(0xFF6B7280),
                                        size: 20,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF5542F6)
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    if (product['price'] != null)
                                      Text(
                                        '\$${product['price']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF5542F6),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        if (_selectedProductName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected: $_selectedProductName',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitForm,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 20),
            label: const Text('Create Discount'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5542F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5542F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _discountType == value;
    return InkWell(
      onTap: () => setState(() => _discountType = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5542F6).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF5542F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFF5542F6)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF5542F6)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
