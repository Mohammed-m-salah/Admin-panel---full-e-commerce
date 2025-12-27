import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/customer_model.dart';
import '../../logic/cubit/customer_cubit.dart';

class UpdateCustomerDialog extends StatefulWidget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String status;

  const UpdateCustomerDialog({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.status,
  });

  @override
  State<UpdateCustomerDialog> createState() => _UpdateCustomerDialogState();
}

class _UpdateCustomerDialogState extends State<UpdateCustomerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late String selectedCity;
  late String selectedStatus;

  bool _isLoading = false;

  // قائمة المدن المتاحة
  final List<String> _cities = [
    'Gaza',
    'Rafah',
    'Khan-yonis',
    'Magazi',
    'Brij',
    'Other'
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);

    // التحقق من أن المدينة موجودة في القائمة
    // إذا لم تكن موجودة، نستخدم 'Other' كقيمة افتراضية
    if (widget.city.isEmpty) {
      selectedCity = 'Gaza';
    } else if (_cities.contains(widget.city)) {
      selectedCity = widget.city;
    } else {
      selectedCity = 'Other';
    }

    // التحقق من الحالة
    final statusLower = widget.status.toLowerCase();
    if (statusLower == 'active') {
      selectedStatus = 'Active';
    } else if (statusLower == 'inactive') {
      selectedStatus = 'Inactive';
    } else {
      selectedStatus = 'Active';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateCustomer() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final customer = CustomerModel(
      id: widget.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      city: selectedCity,
      status: selectedStatus.toLowerCase(),
    );

    try {
      await context.read<CustomerCubit>().updateCustomer(customer);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          color: Color(0xFF5542F6), size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Edit Customer',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937)),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF5542F6), Color(0xFF7C3AED)]),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          widget.name.isNotEmpty
                              ? widget.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1F2937))),
                          const SizedBox(height: 4),
                          Text(widget.email,
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                      'Enter customer name', Icons.person_outline)),
              const SizedBox(height: 16),
              _buildLabel('Email Address'),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration(
                      'example@email.com', Icons.email_outlined)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Phone Number'),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: _phoneController,
                            decoration: _inputDecoration(
                                '+970 5X XXX XXXX', Icons.phone_outlined)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('City'),
                        const SizedBox(height: 8),
                        _buildDropdown(
                            value: selectedCity,
                            items: _cities,
                            onChanged: (value) =>
                                setState(() => selectedCity = value!)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Status'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildStatusOption(
                          'Active', Icons.check_circle_outline)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatusOption(
                          'Inactive', Icons.cancel_outlined)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // زر الإلغاء
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateCustomer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5542F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Customer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w500, color: Color(0xFF374151)));

  Widget _buildStatusOption(String status, IconData icon) {
    final isSelected = selectedStatus.toLowerCase() == status.toLowerCase();
    final color =
        status == 'Active' ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return InkWell(
      onTap: () => setState(() => selectedStatus = status),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
            border: Border.all(
                color: isSelected ? color : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected ? color.withValues(alpha: 0.1) : Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20, color: isSelected ? color : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(status,
                style: TextStyle(
                    color: isSelected ? color : const Color(0xFF6B7280),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF5542F6), width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  Widget _buildDropdown(
          {required String value,
          required List<String> items,
          required ValueChanged<String?> onChanged}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
