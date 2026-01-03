import 'package:flutter/material.dart';

class TopProducts extends StatelessWidget {
  const TopProducts({super.key});

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
          _buildHeader(),
          const SizedBox(height: 16),
          _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Top Selling Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        TextButton(
          onPressed: () {},
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

  Widget _buildProductsList() {
    final products = [
      {'name': 'iPhone 15 Pro Max', 'sales': 324, 'revenue': '\$389,076'},
      {'name': 'MacBook Pro M3', 'sales': 186, 'revenue': '\$464,814'},
      {'name': 'AirPods Pro 2', 'sales': 452, 'revenue': '\$112,548'},
      {'name': 'iPad Air', 'sales': 267, 'revenue': '\$160,133'},
      {'name': 'Apple Watch Ultra', 'sales': 198, 'revenue': '\$158,202'},
    ];

    return Column(
      children: products.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;
        return Column(
          children: [
            _ProductItem(
              rank: index + 1,
              name: product['name'] as String,
              sales: '${product['sales']} sales',
              revenue: product['revenue'] as String,
            ),
            if (index < products.length - 1)
              const Divider(height: 24, color: Color(0xFFE5E7EB)),
          ],
        );
      }).toList(),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final int rank;
  final String name;
  final String sales;
  final String revenue;

  const _ProductItem({
    required this.rank,
    required this.name,
    required this.sales,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isTopThree
                ? const Color(0xFF5542F6).withValues(alpha: 0.1)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isTopThree
                    ? const Color(0xFF5542F6)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sales,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Text(
          revenue,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}
