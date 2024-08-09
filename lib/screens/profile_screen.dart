import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'prediction_analytics_screen.dart';

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
          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(userData['name'] ?? 'User'),
                const SizedBox(height: 24),
                _buildInfoTile('Email', userData['email']),
                _buildInfoTile('Phone', userData['phone_number']),
                _buildInfoTile('Country', userData['country_name']),
                _buildInfoTile('Subscription', userData['subscription_status']),
                _buildInfoTile('Member Since', userData['member_since']),
                _buildInfoTile('Last Login', userData['last_login']),
                const SizedBox(height: 24),
                _buildButton(
                  context,
                  'View Prediction Analytics',
                  Icons.bar_chart,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PredictionAnalyticsScreen()),
                  ),
                ),
                _buildButton(
                  context,
                  'Change Password',
                  Icons.lock,
                  () => _launchURL('https://footballprediction.site/login'),
                ),
                _buildButton(
                  context,
                  'Subscription Plans',
                  Icons.credit_card,
                  () => _launchURL(
                      'https://footballprediction.site/subscription/plans'),
                ),
                const SizedBox(height: 24),
                _buildLogoutButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
              style: TextStyle(fontSize: 36, color: Colors.blue.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
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
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(200, 50),
        ),
        child: const Text('Logout'),
      ),
    );
  }
}
