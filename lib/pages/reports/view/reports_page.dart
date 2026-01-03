import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/report_stat_card.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/order_status_chart.dart';
import 'widgets/top_products.dart';
import 'widgets/sales_by_category.dart';
import 'widgets/recent_transactions.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = 'This Month';

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            _buildChartsRow(),
            const SizedBox(height: 24),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBackButton(),
        Expanded(child: _buildTitleSection()),
        _buildActions(),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
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
        color: const Color(0xFF6B7280),
        tooltip: 'Back',
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports & Analytics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your business performance and insights',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildPeriodDropdown(),
        const SizedBox(width: 12),
        _buildExportButton(),
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _periods.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedPeriod = value!);
          },
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.download_outlined, size: 20),
      label: const Text('Export Report'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5542F6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return const Row(
      children: [
        Expanded(
          child: ReportStatCard(
            title: 'Total Revenue',
            value: '\$124,563.00',
            icon: Icons.attach_money,
            color: Color(0xFF10B981),
            change: '+12.5%',
            isPositive: true,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'Total Orders',
            value: '1,245',
            icon: Icons.shopping_cart_outlined,
            color: Color(0xFF5542F6),
            change: '+8.2%',
            isPositive: true,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'Total Customers',
            value: '856',
            icon: Icons.people_outline,
            color: Color(0xFF3B82F6),
            change: '+5.1%',
            isPositive: true,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'Avg. Order Value',
            value: '\$100.05',
            icon: Icons.trending_up,
            color: Color(0xFF8B5CF6),
            change: '+3.7%',
            isPositive: true,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ReportStatCard(
            title: 'Conversion Rate',
            value: '3.24%',
            icon: Icons.show_chart,
            color: Color(0xFFF59E0B),
            change: '-0.8%',
            isPositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: RevenueChart(),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: OrderStatusChart(),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: TopProducts(),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: SalesByCategory(),
        ),
        SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: RecentTransactions(),
        ),
      ],
    );
  }
}
