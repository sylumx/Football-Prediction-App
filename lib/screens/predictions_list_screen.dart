import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/timezone_provider.dart';
import '../services/predictions_service.dart';
import '../models/prediction.dart';
import 'prediction_details_screen.dart';
import '../widgets/user_menu.dart';
import 'subscription_required_screen.dart';

class PredictionsListScreen extends StatefulWidget {
  const PredictionsListScreen({Key? key}) : super(key: key);

  @override
  _PredictionsListScreenState createState() => _PredictionsListScreenState();
}

class _PredictionsListScreenState extends State<PredictionsListScreen> {
  Map<String, List<Prediction>> predictionsByDate = {};
  final PredictionsService _service = PredictionsService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndFetchPredictions();
  }

  Future<void> _checkSubscriptionAndFetchPredictions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkSubscriptionStatus();

    if (authProvider.isSubscriptionActive) {
      fetchPredictions();
    } else {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SubscriptionRequiredScreen()),
        );
      });
    }
  }

  Future<void> fetchPredictions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.fetchPredictions();
      if (data != null) {
        setState(() {
          predictionsByDate = _groupPredictionsByDate(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load predictions. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, List<Prediction>> _groupPredictionsByDate(
      Map<String, dynamic> data) {
    Map<String, List<Prediction>> grouped = {};
    data.forEach((date, dailyData) {
      final predictions = (dailyData['predictions'] as List<dynamic>? ?? [])
          .map((prediction) => Prediction.fromJson(prediction))
          .toList();
      grouped[date] = predictions;
    });
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Premium Betting Forecasts'),
        actions: const [
          UserMenu(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : RefreshIndicator(
                  onRefresh: _checkSubscriptionAndFetchPredictions,
                  child: predictionsByDate.isEmpty
                      ? _buildNoPredictionsContent()
                      : ListView.builder(
                          itemCount: predictionsByDate.length,
                          itemBuilder: (context, index) {
                            String date =
                                predictionsByDate.keys.elementAt(index);
                            List<Prediction> predictions =
                                predictionsByDate[date]!;
                            return _buildDateSection(date, predictions);
                          },
                        ),
                ),
    );
  }

  Widget _buildNoPredictionsContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.sports_soccer,
              size: 100,
              color: Colors.indigo,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Predictions Available Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Our expert analysts are hard at work crafting premium predictions just for you. Stay tuned for high-quality betting tips that will give you the edge!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildSubscriptionPromotion(),
            const SizedBox(height: 30),
            _buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPromotion() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Unlock Premium Predictions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Get access to exclusive betting tips and increase your chances of winning!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/subscription');
              },
              child: const Text('Subscribe Now'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Daily premium predictions',
      'Expert analysis from seasoned professionals',
      'Comprehensive stats and insights',
      'Exclusive access to VIP tips',
      'Personalized betting strategies',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Subscribe?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 10),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDateSection(String date, List<Prediction> predictions) {
    double totalOdds =
        predictions.fold(1, (prev, pred) => prev * pred.recommendedOdd);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(date),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800]),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Odds: ${totalOdds.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, color: Colors.indigo[600]),
              ),
            ],
          ),
        ),
        ...predictions.map((prediction) => _buildPredictionCard(prediction)),
      ],
    );
  }

  Widget _buildPredictionCard(Prediction prediction) {
    final timezoneProvider =
        Provider.of<TimezoneProvider>(context, listen: false);
    final localTime = timezoneProvider.convertToLocalTime(prediction.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PredictionDetailsScreen(prediction: prediction)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${prediction.homeTeam} vs ${prediction.awayTeam}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    _formatTime(localTime),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${prediction.leagueName} (${prediction.leagueCountry})',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Bet Type', prediction.betType, Colors.blue),
                  _buildInfoColumn(
                      'Odds',
                      prediction.recommendedOdd.toStringAsFixed(2),
                      Colors.green),
                  _buildInfoColumn(
                      'Accuracy',
                      '${(prediction.confidenceLevel * 100).toStringAsFixed(0)}%',
                      Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
