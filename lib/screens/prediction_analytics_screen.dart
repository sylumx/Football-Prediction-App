import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictionAnalyticsScreen extends StatelessWidget {
  const PredictionAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Analytics'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userData = authProvider.userData;
          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, 'Overall Performance'),
                _buildPerformanceCard(userData['overall_performance']),
                _buildSectionHeader(context, 'Daily Performance (ROI)'),
                _buildDailyPerformanceChart(
                    context, userData['daily_performance']),
                _buildSectionHeader(context, 'League Performance'),
                _buildLeaguePerformanceList(
                    context, userData['league_performance']),
                _buildSectionHeader(context, 'Bet Type Performance'),
                _buildBetTypePerformanceList(
                    context, userData['bet_type_performance']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic>? performance) {
    if (performance == null) return Container();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceRow(
                'Total Games', performance['total_games'].toString()),
            _buildPerformanceRow('Winning Predictions',
                performance['winning_predictions'].toString()),
            _buildPerformanceRow('Losing Predictions',
                performance['losing_predictions'].toString()),
            _buildPerformanceRow('Pending Predictions',
                performance['pending_predictions'].toString()),
            _buildPerformanceRow('Win Rate', '${performance['win_rate']}%'),
            _buildPerformanceRow('Hit Rate', '${performance['hit_rate']}%'),
            _buildPerformanceRow(
                'Total Stake', '\$${performance['total_stake']}'),
            _buildPerformanceRow(
                'Total Profit/Loss', '\$${performance['total_profit_loss']}'),
            _buildPerformanceRow('ROI', '${performance['roi']}%'),
            _buildPerformanceRow(
                'Average Odds', performance['average_odds'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDailyPerformanceChart(
      BuildContext context, List<dynamic>? dailyPerformance) {
    if (dailyPerformance == null) return Container();
    List<FlSpot> spots = dailyPerformance.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['roi'].toDouble());
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  if (value % 5 == 0) {
                    return Text(value.toInt().toString());
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%');
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
              show: true, border: Border.all(color: Colors.grey[300]!)),
          minX: 0,
          maxX: dailyPerformance.length.toDouble() - 1,
          minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
          maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceList(BuildContext context,
      List<dynamic>? performanceData, String nameKey, String totalKey) {
    if (performanceData == null) return Container();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: performanceData.length,
      itemBuilder: (context, index) {
        final item = performanceData[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(item[nameKey],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Win Rate: ${item['win_rate'].toStringAsFixed(2)}%, ROI: ${item['roi'].toStringAsFixed(2)}%',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Text(
              'Predictions: ${item[totalKey]}',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaguePerformanceList(
      BuildContext context, List<dynamic>? leaguePerformance) {
    return _buildPerformanceList(
        context, leaguePerformance, 'league_name', 'total_predictions');
  }

  Widget _buildBetTypePerformanceList(
      BuildContext context, List<dynamic>? betTypePerformance) {
    return _buildPerformanceList(
        context, betTypePerformance, 'bet_type', 'total_predictions');
  }
}
