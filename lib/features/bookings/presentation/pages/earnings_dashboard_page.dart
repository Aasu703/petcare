import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/bookings/presentation/view_model/earnings_view_model.dart';

class EarningsDashboardPage extends ConsumerStatefulWidget {
  const EarningsDashboardPage({super.key});

  @override
  ConsumerState<EarningsDashboardPage> createState() =>
      _EarningsDashboardPageState();
}

class _EarningsDashboardPageState extends ConsumerState<EarningsDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(earningsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Dashboard'),
        backgroundColor: AppColors.iconPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(earningsProvider.notifier).load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : state.earnings == null
          ? const Center(child: Text('No earnings data'))
          : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, EarningsState state) {
    final earnings = state.earnings!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Earnings',
                  value: '\$${earnings.totalEarnings.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'This Month',
                  value: '\$${earnings.monthlyEarnings.toStringAsFixed(2)}',
                  icon: Icons.calendar_month,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Completed Appointments',
            value: earnings.completedAppointments.toString(),
            icon: Icons.check_circle,
            color: AppColors.iconPrimaryColor,
          ),

          const SizedBox(height: 28),
          const Text(
            'Earnings per Day',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Bar chart
          SizedBox(
            height: 220,
            child: _EarningsBarChart(dailyEarnings: earnings.dailyEarnings),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsBarChart extends StatelessWidget {
  final Map<String, double> dailyEarnings;

  const _EarningsBarChart({required this.dailyEarnings});

  @override
  Widget build(BuildContext context) {
    if (dailyEarnings.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    // Sort by date, take last 14 days max
    final sortedKeys = dailyEarnings.keys.toList()..sort();
    final recentKeys = sortedKeys.length > 14
        ? sortedKeys.sublist(sortedKeys.length - 14)
        : sortedKeys;

    final maxY = dailyEarnings.values.fold<double>(
      0,
      (max, v) => v > max ? v : max,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '\$${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= recentKeys.length) {
                  return const SizedBox.shrink();
                }
                final dt = DateTime.tryParse(recentKeys[idx]);
                final label = dt != null ? DateFormat('d').format(dt) : '';
                return Text(label, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(recentKeys.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyEarnings[recentKeys[i]] ?? 0,
                color: AppColors.iconPrimaryColor,
                width: recentKeys.length > 10 ? 8 : 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
