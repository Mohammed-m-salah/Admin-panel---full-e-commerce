import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/order_model.dart';
import '../../logic/cubit/order_cubit.dart';

class UpdateOrderStatusDialog extends StatefulWidget {
  final OrderModel order;

  const UpdateOrderStatusDialog({super.key, required this.order});

  @override
  State<UpdateOrderStatusDialog> createState() => _UpdateOrderStatusDialogState();
}

class _UpdateOrderStatusDialogState extends State<UpdateOrderStatusDialog> {
  late String _selectedStatus;
  late String _selectedPaymentStatus;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _orderStatuses = [
    {
      'value': 'pending',
      'label': 'Pending',
      'icon': Icons.hourglass_empty,
      'color': const Color(0xFFF59E0B),
      'description': 'Order is awaiting processing',
    },
    {
      'value': 'processing',
      'label': 'Processing',
      'icon': Icons.sync,
      'color': const Color(0xFF3B82F6),
      'description': 'Order is being prepared',
    },
    {
      'value': 'shipped',
      'label': 'Shipped',
      'icon': Icons.local_shipping_outlined,
      'color': const Color(0xFF8B5CF6),
      'description': 'Order has been shipped',
    },
    {
      'value': 'delivered',
      'label': 'Delivered',
      'icon': Icons.check_circle_outline,
      'color': const Color(0xFF10B981),
      'description': 'Order has been delivered',
    },
    {
      'value': 'cancelled',
      'label': 'Cancelled',
      'icon': Icons.cancel_outlined,
      'color': const Color(0xFFEF4444),
      'description': 'Order has been cancelled',
    },
    {
      'value': 'refunded',
      'label': 'Refunded',
      'icon': Icons.replay,
      'color': const Color(0xFF6B7280),
      'description': 'Order has been refunded',
    },
  ];

  final List<Map<String, dynamic>> _paymentStatuses = [
    {
      'value': 'pending',
      'label': 'Pending',
      'color': const Color(0xFFF59E0B),
    },
    {
      'value': 'paid',
      'label': 'Paid',
      'color': const Color(0xFF10B981),
    },
    {
      'value': 'failed',
      'label': 'Failed',
      'color': const Color(0xFFEF4444),
    },
    {
      'value': 'refunded',
      'label': 'Refunded',
      'color': const Color(0xFF6B7280),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _selectedPaymentStatus = widget.order.paymentStatus;
    _notesController.text = widget.order.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 550,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content - Scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info
                    _buildOrderInfo(),
                    const SizedBox(height: 24),

                    // Order Status
                    _buildSectionTitle('Order Status'),
                    const SizedBox(height: 12),
                    _buildStatusGrid(),
                    const SizedBox(height: 24),

                    // Payment Status
                    _buildSectionTitle('Payment Status'),
                    const SizedBox(height: 12),
                    _buildPaymentStatusRow(),
                    const SizedBox(height: 24),

                    // Notes
                    _buildSectionTitle('Notes (Optional)'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any notes about this status update...',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF5542F6), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
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
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order: ${widget.order.orderNumber}',
                  style: const TextStyle(
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

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF5542F6).withValues(alpha: 0.1),
            child: Text(
              widget.order.customerName[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF5542F6),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.order.itemCount} items',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.order.formattedTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.order.formattedDate,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
        fontSize: 14,
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _orderStatuses.map((status) {
        final isSelected = _selectedStatus == status['value'];
        final Color color = status['color'];

        return InkWell(
          onTap: () => setState(() => _selectedStatus = status['value']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    status['icon'],
                    size: 18,
                    color: isSelected ? color : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['label'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected ? color : const Color(0xFF1F2937),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: color,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentStatusRow() {
    return Row(
      children: _paymentStatuses.map((status) {
        final isSelected = _selectedPaymentStatus == status['value'];
        final Color color = status['color'];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: status != _paymentStatuses.last ? 12 : 0,
            ),
            child: InkWell(
              onTap: () =>
                  setState(() => _selectedPaymentStatus = status['value']),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status['label'],
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : const Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
            onPressed: () => Navigator.pop(context),
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
          ElevatedButton(
            onPressed: _isLoading ? null : _updateStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5542F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Update Status'),
          ),
        ],
      ),
    );
  }

  void _updateStatus() {
    if (widget.order.id == null) return;

    setState(() => _isLoading = true);

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    context.read<OrderCubit>().updateOrderAndPaymentStatus(
          widget.order.id!,
          _selectedStatus,
          _selectedPaymentStatus,
          notes,
        );

    Navigator.pop(context);
  }
}
