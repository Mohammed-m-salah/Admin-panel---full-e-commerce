import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrderStatusChart extends StatelessWidget {
  const OrderStatusChart({super.key});

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
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(_buildChartData()),
          ),
          const SizedBox(height: 24),
          _buildLegendList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Distribution by status',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  PieChartData _buildChartData() {
    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: [
        _buildSection(35, 'Delivered', const Color(0xFF10B981)),
        _buildSection(25, 'Processing', const Color(0xFF3B82F6)),
        _buildSection(20, 'Pending', const Color(0xFFF59E0B)),
        _buildSection(15, 'Shipped', const Color(0xFF8B5CF6)),
        _buildSection(5, 'Cancelled', const Color(0xFFEF4444)),
      ],
    );
  }

  PieChartSectionData _buildSection(double value, String title, Color color) {
    return PieChartSectionData(
      value: value,
      title: '${value.toInt()}%',
      color: color,
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendList() {
    final legendItems = [
      {'label': 'Delivered', 'color': const Color(0xFF10B981), 'count': '437'},
      {'label': 'Processing', 'color': const Color(0xFF3B82F6), 'count': '311'},
      {'label': 'Pending', 'color': const Color(0xFFF59E0B), 'count': '249'},
      {'label': 'Shipped', 'color': const Color(0xFF8B5CF6), 'count': '186'},
      {'label': 'Cancelled', 'color': const Color(0xFFEF4444), 'count': '62'},
    ];

    return Column(
      children: legendItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLegendItem(
            item['label'] as String,
            item['color'] as Color,
            item['count'] as String,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color, String count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
