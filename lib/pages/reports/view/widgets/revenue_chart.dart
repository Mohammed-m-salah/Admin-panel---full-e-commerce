import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

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
            height: 300,
            child: LineChart(_buildChartData()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Monthly revenue performance',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildLegendItem('Revenue', const Color(0xFF5542F6)),
            const SizedBox(width: 16),
            _buildLegendItem('Orders', const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20000,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xFFE5E7EB),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 20000,
            getTitlesWidget: _leftTitleWidgets,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 100000,
      lineBarsData: [
        _revenueLineData(),
        _ordersLineData(),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => const Color(0xFF1F2937),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '\$${spot.y.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (value.toInt() >= 0 && value.toInt() < months.length) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          months[value.toInt()],
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      );
    }
    return const Text('');
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      '\$${(value / 1000).toStringAsFixed(0)}k',
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 12,
      ),
    );
  }

  LineChartBarData _revenueLineData() {
    return LineChartBarData(
      spots: const [
        FlSpot(0, 35000),
        FlSpot(1, 42000),
        FlSpot(2, 38000),
        FlSpot(3, 55000),
        FlSpot(4, 48000),
        FlSpot(5, 62000),
        FlSpot(6, 71000),
        FlSpot(7, 68000),
        FlSpot(8, 75000),
        FlSpot(9, 82000),
        FlSpot(10, 78000),
        FlSpot(11, 92000),
      ],
      isCurved: true,
      color: const Color(0xFF5542F6),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF5542F6).withValues(alpha: 0.1),
      ),
    );
  }

  LineChartBarData _ordersLineData() {
    return LineChartBarData(
      spots: const [
        FlSpot(0, 20000),
        FlSpot(1, 28000),
        FlSpot(2, 25000),
        FlSpot(3, 35000),
        FlSpot(4, 32000),
        FlSpot(5, 42000),
        FlSpot(6, 48000),
        FlSpot(7, 45000),
        FlSpot(8, 52000),
        FlSpot(9, 58000),
        FlSpot(10, 55000),
        FlSpot(11, 65000),
      ],
      isCurved: true,
      color: const Color(0xFF10B981),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
      ),
    );
  }
}
