import 'dart:typed_data';
import 'package:core_dashboard/pages/products/data/model/product_model.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_cubit.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProductDialog extends StatefulWidget {
  final ProductModel product;

  const UpdateProductDialog({
    super.key,
    required this.product,
  });

  @override
  State<UpdateProductDialog> createState() => _UpdateProductDialogState();
}

class _UpdateProductDialogState extends State<UpdateProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late String selectedCategory;
  late int selectedStockStatus;
  final _formKey = GlobalKey<FormState>();

  // متغيرات الصورة
  Uint8List? _newImageBytes;
  String? _newImageName;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // تعبئة الحقول بالبيانات الحالية
    _nameController = TextEditingController(text: widget.product.name);
    _descController = TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    selectedCategory = widget.product.category ?? 'Men';

    // تحويل stockStatus من String إلى int
    selectedStockStatus = _getStockStatusInt(widget.product.stockStatus);
  }

  int _getStockStatusInt(String? status) {
    switch (status) {
      case 'In Stock':
        return 1;
      case 'Low Stock':
        return 2;
      case 'Out of Stock':
        return 3;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // دالة اختيار صورة جديدة
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newImageBytes = bytes;
          _newImageName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  // دالة الحصول على Content-Type
  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // دالة رفع الصورة الجديدة
  Future<String?> _uploadNewImage() async {
    if (_newImageBytes == null || _newImageName == null) {
      return null;
    }

    try {
      setState(() => _isUploadingImage = true);

      final supabase = Supabase.instance.client;
      final extension = _newImageName!.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final contentType = _getContentType(_newImageName!);

      await supabase.storage.from('products').uploadBinary(
            fileName,
            _newImageBytes!,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: contentType,
            ),
          );

      final imageUrl =
          supabase.storage.from('products').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // الصورة
              const Text(
                'Product Image',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              _buildImageSection(),
              const SizedBox(height: 20),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    const Text(
                      'Product Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the product name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                      decoration: _inputDecoration('Enter product name'),
                    ),
                    const SizedBox(height: 16),

                    // الوصف
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      decoration: _inputDecoration('Enter product description'),
                    ),
                    const SizedBox(height: 16),

                    // السعر والفئة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter price';
                                  }
                                  final price = double.tryParse(value);
                                  if (price == null || price <= 0) {
                                    return 'Invalid price';
                                  }
                                  return null;
                                },
                                decoration: _inputDecoration('0.00').copyWith(
                                  prefixText: '\$ ',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown<String>(
                                value: selectedCategory,
                                items: ['Men', 'Women', 'Kids', 'Shoes'],
                                onChanged: (value) {
                                  setState(() => selectedCategory = value!);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // الحالة
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown<int>(
                      value: selectedStockStatus,
                      items: [1, 2, 3],
                      itemLabels: {
                        1: 'In Stock',
                        2: 'Low Stock',
                        3: 'Out of Stock',
                      },
                      onChanged: (value) {
                        setState(() => selectedStockStatus = value!);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // الأزرار
              BlocConsumer<ProductCubit, ProductState>(
                listener: (context, state) {
                  if (state is ProductOperationSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  if (state is ProductError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is ProductLoading || _isUploadingImage;

                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5542F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Update Product'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء قسم الصورة
  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF9FAFB),
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(8),
        child: _newImageBytes != null
            // صورة جديدة تم اختيارها
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _newImageBytes!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  _buildImageOverlay(),
                ],
              )
            : widget.product.imageUrl != null &&
                    widget.product.imageUrl!.isNotEmpty
                // الصورة الحالية من السيرفر
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product.imageUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildNoImagePlaceholder();
                          },
                        ),
                      ),
                      _buildImageOverlay(),
                    ],
                  )
                // لا توجد صورة
                : _buildNoImagePlaceholder(),
      ),
    );
  }

  Widget _buildImageOverlay() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'Change',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF9CA3AF)),
        SizedBox(height: 8),
        Text(
          'Click to upload image',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    Map<T, String>? itemLabels,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabels?[item] ?? item.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // رفع الصورة الجديدة إذا تم اختيار واحدة
      String? imageUrl = widget.product.imageUrl;
      if (_newImageBytes != null) {
        final newUrl = await _uploadNewImage();
        if (newUrl != null) {
          imageUrl = newUrl;
        }
      }

      // تحويل int إلى String للـ stockStatus
      final stockStatusString = selectedStockStatus == 1
          ? 'In Stock'
          : selectedStockStatus == 2
              ? 'Low Stock'
              : 'Out of Stock';

      final updatedProduct = ProductModel(
        id: widget.product.id, // مهم جداً! نفس الـ id
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        category: selectedCategory,
        stockStatus: stockStatusString,
        imageUrl: imageUrl,
        rating: widget.product.rating, // نحافظ على التقييم
        stock: widget.product.stock, // نحافظ على المخزون
      );

      if (mounted) {
        context.read<ProductCubit>().updateProduct(updatedProduct);
      }
    }
  }
}
