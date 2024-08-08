import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction.dart';

class PredictionDetailsScreen extends StatelessWidget {
  final Prediction prediction;

  const PredictionDetailsScreen({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.indigo[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${prediction.homeTeam} vs ${prediction.awayTeam}',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(prediction.date),
            style: TextStyle(fontSize: 16, color: Colors.indigo[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('League',
                '${prediction.leagueName} (${prediction.leagueCountry})'),
            _buildDetailRow('Bet Type', prediction.betType),
            _buildDetailRow('Recommended Odds',
                prediction.recommendedOdd.toStringAsFixed(2)),
            _buildDetailRow('Confidence',
                '${(prediction.confidenceLevel * 100).toStringAsFixed(1)}%'),
            _buildDetailRow('Weather', prediction.weather ?? 'N/A'),
            _buildDetailRow('Venue', prediction.venue ?? 'N/A'),
            _buildDetailRow('Predicted Score', prediction.predictedScore),
            _buildDetailRow('Predicted Home Score',
                prediction.predictedHomeScore?.toStringAsFixed(2) ?? 'N/A'),
            _buildDetailRow('Predicted Away Score',
                prediction.predictedAwayScore?.toStringAsFixed(2) ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  color: Colors.indigo[700]),
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

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y HH:mm').format(date);
  }
}
