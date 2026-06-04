import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  final Color _deepOcean = const Color(0xFF0B192C);
  final Color _neonTeal = const Color(0xFF00FFCA);
  final Color _softBg = const Color(0xFFF4F7F9);

  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await ApiClient.instance.get('/driver/notifications');
      if (response.statusCode == 200) {
        setState(() {
          _notifications = response.data is List ? response.data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not fetch live notifications. Showing offline alerts.';
        _isLoading = false;
        // Fallback static alerts
        _notifications = [
          {'title': 'Heavy Rain Warning', 'message': 'Proceed with caution on coastal roads.', 'type': 'warning'},
          {'title': 'System Sync Successful', 'message': 'All your offline trips have been uploaded.', 'type': 'success'},
          {'title': 'LGU Announcement', 'message': 'Terminal fees updated for Bongao Port. Please check the new matrix.', 'type': 'info'},
        ];
      });
    }
  }

  Color _getColorForType(String? type) {
    if (type == 'warning') return Colors.orange;
    if (type == 'success') return _neonTeal;
    return _deepOcean; // info or default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBg,
      appBar: AppBar(
        backgroundColor: _deepOcean,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.redAccent.withOpacity(0.1),
            width: double.infinity,
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: _notifications.isEmpty
              ? const Center(child: Text("No notifications available."))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return _premiumAlertCard(
                      notif['title'] ?? 'Alert',
                      notif['message'] ?? 'No message provided.',
                      _getColorForType(notif['type']),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _premiumAlertCard(String title, String msg, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border(left: BorderSide(color: accent, width: 4))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: _deepOcean, fontSize: 14)),
          const SizedBox(height: 4),
          Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}