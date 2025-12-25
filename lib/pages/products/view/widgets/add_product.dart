import 'dart:typed_data';
import 'package:core_dashboard/pages/products/data/model/product_model.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_cubit.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String selectedCategory = 'Men';
  int selectedStockStatus = 1;
  final _formKey = GlobalKey<FormState>();

  // متغيرات الصورة
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // دالة اختيار الصورة
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
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة الحصول على Content-Type بناءً على امتداد الملف
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

  // دالة رفع الصورة إلى Supabase Storage
  Future<String?> _uploadImageToSupabase() async {
    if (_selectedImageBytes == null || _selectedImageName == null) {
      return null;
    }

    try {
      setState(() => _isUploadingImage = true);

      final supabase = Supabase.instance.client;

      // إنشاء اسم فريد للملف
      final extension = _selectedImageName!.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

      // تحديد Content-Type
      final contentType = _getContentType(_selectedImageName!);

      // رفع الصورة إلى bucket اسمه "products"
      await supabase.storage.from('products').uploadBinary(
            fileName,
            _selectedImageBytes!,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true, // السماح بالاستبدال إذا كان الملف موجود
              contentType: contentType, // تحديد نوع الملف
            ),
          );

      // الحصول على الرابط العام للصورة
      final imageUrl =
          supabase.storage.from('products').getPublicUrl(fileName);

      return imageUrl;
    } on StorageException catch (e) {
      // خطأ من Supabase Storage
      String errorMessage = 'Storage Error: ';

      if (e.message.contains('Bucket not found')) {
        errorMessage = 'Bucket "products" not found! Create it in Supabase Dashboard.';
      } else if (e.message.contains('not allowed') || e.message.contains('policy')) {
        errorMessage = 'Permission denied! Check RLS policies in Supabase.';
      } else if (e.message.contains('exceed') || e.message.contains('size')) {
        errorMessage = 'File too large! Max size exceeded.';
      } else {
        errorMessage += e.message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
                    'Add New Product',
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

              // رفع الصورة
              const Text(
                'Product Image',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              _buildImagePicker(),
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
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Description should be at least 10 characters';
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
                                  if (price == null) {
                                    return 'Invalid number';
                                  }
                                  if (price <= 0) {
                                    return 'Must be > 0';
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
                        content: Text('Product added successfully!'),
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
                              : const Text('Save Product'),
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

  // Widget لعرض واختيار الصورة
  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(8),
        child: _selectedImageBytes != null
            ? Stack(
                children: [
                  // عرض الصورة المختارة
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // زر إزالة الصورة
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageBytes = null;
                          _selectedImageName = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // زر تغيير الصورة
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click to upload image',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PNG, JPG up to 5MB',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
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
      // رفع الصورة أولاً (إذا تم اختيار صورة)
      String? imageUrl;
      if (_selectedImageBytes != null) {
        imageUrl = await _uploadImageToSupabase();
      }

      final product = ProductModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        category: selectedCategory,
        imageUrl: imageUrl,
        stockStatus: selectedStockStatus == 1
            ? 'In Stock'
            : selectedStockStatus == 2
                ? 'Low Stock'
                : 'Out of Stock',
      );

      if (mounted) {
        context.read<ProductCubit>().addProduct(product);
      }
    }
  }
}
