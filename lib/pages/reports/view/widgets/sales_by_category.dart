import 'package:flutter/material.dart';

class SalesByCategory extends StatelessWidget {
  const SalesByCategory({super.key});

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
          const Text(
            'Sales by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          _buildCategoriesList(),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    final categories = [
      {'name': 'Electronics', 'progress': 0.45, 'color': const Color(0xFF5542F6), 'value': '\$56,200'},
      {'name': 'Clothing', 'progress': 0.32, 'color': const Color(0xFF10B981), 'value': '\$39,840'},
      {'name': 'Home & Garden', 'progress': 0.18, 'color': const Color(0xFF3B82F6), 'value': '\$22,410'},
      {'name': 'Sports', 'progress': 0.12, 'color': const Color(0xFFF59E0B), 'value': '\$14,940'},
      {'name': 'Books', 'progress': 0.08, 'color': const Color(0xFF8B5CF6), 'value': '\$9,960'},
      {'name': 'Other', 'progress': 0.05, 'color': const Color(0xFF6B7280), 'value': '\$6,225'},
    ];

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _CategoryBar(
            name: category['name'] as String,
            progress: category['progress'] as double,
            color: category['color'] as Color,
            value: category['value'] as String,
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String name;
  final double progress;
  final Color color;
  final String value;

  const _CategoryBar({
    required this.name,
    required this.progress,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
