import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionRequiredScreen extends StatelessWidget {
  const SubscriptionRequiredScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/predictions');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscription Required'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/predictions'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text(
                'Active Subscription Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'To view predictions, you need an active subscription. Please subscribe to access this feature.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _launchURL(
                    'https://footballprediction.site/subscription/plans'),
                child: const Text('View Subscription Plans'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/predictions'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}