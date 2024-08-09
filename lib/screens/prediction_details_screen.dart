import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timezone_provider.dart';
import '../models/prediction.dart';

class PredictionDetailsScreen extends StatelessWidget {
  final Prediction prediction;

  const PredictionDetailsScreen({Key? key, required this.prediction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timezoneProvider =
        Provider.of<TimezoneProvider>(context, listen: false);
    final localKickOffTime =
        timezoneProvider.convertToLocalTime(prediction.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(localKickOffTime),
            _buildDetailsCard(context, localKickOffTime),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime localKickOffTime) {
    return Container(
      color: Colors.indigo[50],
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '${prediction.homeTeam} vs ${prediction.awayTeam}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _formatDateTime(localKickOffTime),
            style: TextStyle(fontSize: 18, color: Colors.indigo[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, DateTime localKickOffTime) {
    final timezoneProvider =
        Provider.of<TimezoneProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('League',
                '${prediction.leagueName} (${prediction.leagueCountry})'),
            _buildDivider(),
            _buildDetailRow('Bet Type', prediction.betType),
            _buildDivider(),
            _buildDetailRow('Recommended Odds',
                prediction.recommendedOdd.toStringAsFixed(2)),
            _buildDivider(),
            _buildDetailRow('Confidence',
                '${(prediction.confidenceLevel * 100).toStringAsFixed(1)}%'),
            _buildDivider(),
            _buildDetailRow('Weather', prediction.weather ?? 'N/A'),
            _buildDivider(),
            _buildDetailRow('Venue', prediction.venue ?? 'N/A'),
            _buildDivider(),
            _buildDetailRow('Predicted Score', prediction.predictedScore),
            _buildDivider(),
            _buildDetailRow('Predicted Home Score',
                prediction.predictedHomeScore?.toStringAsFixed(2) ?? 'N/A'),
            _buildDivider(),
            _buildDetailRow('Predicted Away Score',
                prediction.predictedAwayScore?.toStringAsFixed(2) ?? 'N/A'),
            _buildDivider(),
            _buildDetailRow(
                'Local Kickoff Time', _formatTime(localKickOffTime)),
            _buildDivider(),
            _buildDetailRow('Time Zone', timezoneProvider.userTimeZone),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Colors.grey);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('EEEE, MMMM d, y HH:mm').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
