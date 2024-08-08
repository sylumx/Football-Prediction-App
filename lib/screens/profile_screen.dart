import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userData = authProvider.userData;
          debugPrint('User data in ProfileScreen: $userData');
          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoTile('Name', userData['name']),
                _buildInfoTile('Email', userData['email']),
                _buildInfoTile('Phone', userData['phone_number']),
                _buildInfoTile('Country', userData['country_name']),
                _buildInfoTile('Subscription', userData['subscription_status']),
                _buildInfoTile('Member Since', userData['member_since']),
                _buildInfoTile('Last Login', userData['last_login']),
                const SizedBox(height: 24),
                Text('Overall Performance',
                    style: Theme.of(context).textTheme.titleLarge),
                _buildPerformanceCard(userData['overall_performance']),
                const SizedBox(height: 24),
                Text('Daily Performance (ROI)',
                    style: Theme.of(context).textTheme.titleLarge),
                _buildDailyPerformanceChart(userData['daily_performance']),
                const SizedBox(height: 24),
                Text('League Performance',
                    style: Theme.of(context).textTheme.titleLarge),
                _buildLeaguePerformanceList(userData['league_performance']),
                const SizedBox(height: 24),
                Text('Bet Type Performance',
                    style: Theme.of(context).textTheme.titleLarge),
                _buildBetTypePerformanceList(userData['bet_type_performance']),
                const SizedBox(height: 24),
                _buildLinkButton(
                  context,
                  'Change Password',
                  'https://footballprediction.site/login',
                ),
                _buildLinkButton(
                  context,
                  'Subscription Plans',
                  'https://footballprediction.site/subscription/plans',
                ),
                _buildLinkButton(
                  context,
                  'Prediction Analytics',
                  'https://footballprediction.site/prediction-analytics',
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      authProvider.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    debugPrint('Building info tile - Label: $label, Value: $value');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, String label, String url) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          onPressed: () => _launchURL(url),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic>? performance) {
    if (performance == null) return Container();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Games: ${performance['total_games']}'),
            Text('Winning Predictions: ${performance['winning_predictions']}'),
            Text('Losing Predictions: ${performance['losing_predictions']}'),
            Text('Pending Predictions: ${performance['pending_predictions']}'),
            Text('Win Rate: ${performance['win_rate']}%'),
            Text('Hit Rate: ${performance['hit_rate']}%'),
            Text('Total Stake: \$${performance['total_stake']}'),
            Text('Total Profit/Loss: \$${performance['total_profit_loss']}'),
            Text('ROI: ${performance['roi']}%'),
            Text('Average Odds: ${performance['average_odds']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPerformanceChart(List<dynamic>? dailyPerformance) {
    if (dailyPerformance == null) return Container();
    List<FlSpot> spots = dailyPerformance.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['roi'].toDouble());
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: dailyPerformance.length.toDouble() - 1,
          minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
          maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaguePerformanceList(List<dynamic>? leaguePerformance) {
    if (leaguePerformance == null) return Container();
    return Column(
      children: leaguePerformance.map((league) {
        return ListTile(
          title: Text(league['league_name']),
          subtitle: Text(
              'Win Rate: ${league['win_rate'].toStringAsFixed(2)}%, ROI: ${league['roi'].toStringAsFixed(2)}%'),
          trailing: Text('Predictions: ${league['total_predictions']}'),
        );
      }).toList(),
    );
  }

  Widget _buildBetTypePerformanceList(List<dynamic>? betTypePerformance) {
    if (betTypePerformance == null) return Container();
    return Column(
      children: betTypePerformance.map((betType) {
        return ListTile(
          title: Text(betType['bet_type']),
          subtitle: Text(
              'Win Rate: ${betType['win_rate'].toStringAsFixed(2)}%, ROI: ${betType['roi'].toStringAsFixed(2)}%'),
          trailing: Text('Predictions: ${betType['total_predictions']}'),
        );
      }).toList(),
    );
  }
}
