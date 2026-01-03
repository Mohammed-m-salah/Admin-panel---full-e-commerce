import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/orders'),
          child: const Text(
            'View All',
            style: TextStyle(
              color: Color(0xFF5542F6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    final transactions = [
      {
        'id': '#ORD-7841',
        'customer': 'John Doe',
        'amount': '\$256.00',
        'status': 'Completed',
        'time': '2 min ago'
      },
      {
        'id': '#ORD-7840',
        'customer': 'Sarah Wilson',
        'amount': '\$89.50',
        'status': 'Pending',
        'time': '15 min ago'
      },
      {
        'id': '#ORD-7839',
        'customer': 'Mike Johnson',
        'amount': '\$1,245.00',
        'status': 'Completed',
        'time': '1 hr ago'
      },
      {
        'id': '#ORD-7838',
        'customer': 'Emily Brown',
        'amount': '\$567.80',
        'status': 'Processing',
        'time': '2 hrs ago'
      },
      {
        'id': '#ORD-7837',
        'customer': 'David Lee',
        'amount': '\$320.00',
        'status': 'Completed',
        'time': '3 hrs ago'
      },
    ];

    return Column(
      children: transactions.asMap().entries.map((entry) {
        final index = entry.key;
        final tx = entry.value;
        return Column(
          children: [
            _TransactionItem(
              id: tx['id'] as String,
              customer: tx['customer'] as String,
              amount: tx['amount'] as String,
              status: tx['status'] as String,
              time: tx['time'] as String,
            ),
            if (index < transactions.length - 1)
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
          ],
        );
      }).toList(),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String id;
  final String customer;
  final String amount;
  final String status;
  final String time;

  const _TransactionItem({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.time,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCustomerInfo(),
        ),
        _buildAmountAndStatus(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF5542F6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          customer.isNotEmpty ? customer[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5542F6),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          customer,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$id  •  $time',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountAndStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
