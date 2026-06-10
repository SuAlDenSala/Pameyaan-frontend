import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class TripHistoryTab extends StatefulWidget {
  const TripHistoryTab({super.key});

  @override
  State<TripHistoryTab> createState() => _TripHistoryTabState();
}

class _TripHistoryTabState extends State<TripHistoryTab> {
  bool _isLoading = true;
  List<dynamic> _trips = [];
  final Color _deepOcean = AppColors.deepOcean;
  final Color _neonTeal = AppColors.neonTeal;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    const cacheKey = 'commuter_history_cache';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      setState(() {
        _trips = jsonDecode(cachedData);
        _isLoading = false;
      });
    }

    try {
      final response = await ApiClient.instance.get('/commuters/me/trips');
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, jsonEncode(response.data));
        if (!mounted) return;
        setState(() {
          _trips = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // NEW: THE REAL RATING DIALOG LOGIC
  // ==========================================
  void _showRatingDialog(BuildContext context, dynamic trip) {
    int _rating = 5;
    bool _isFlagged = false;
    TextEditingController _feedbackController = TextEditingController();
    bool _isSubmitting = false;
    
    final String driverId = trip['driver_id'] ?? '';

    if (driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot rate this mock trip.'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Rate your trip', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('How was your ride with ${trip['driver_name'] ?? 'the driver'}?', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setDialogState(() => _rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _feedbackController,
                    decoration: InputDecoration(
                      hintText: 'Optional feedback...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Flag inappropriate behavior or colorum operation', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                    value: _isFlagged,
                    activeColor: Colors.redAccent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? value) {
                      setDialogState(() => _isFlagged = value ?? false);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () async {
                  setDialogState(() => _isSubmitting = true);
                  try {
                    final response = await ApiClient.instance.post(
                      '/drivers/$driverId/rate',
                      data: {
                        "rating_score": _rating,
                        "feedback": _feedbackController.text,
                        "is_flagged": _isFlagged
                      },
                    );
                    if (response.statusCode == 201) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating submitted. Thank you for keeping the community safe!'), backgroundColor: AppColors.neonTeal),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to submit rating. You can only rate a driver once per hour.'), backgroundColor: Colors.redAccent),
                    );
                    setDialogState(() => _isSubmitting = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepOcean),
                child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDarkMode;
    final Color bgColor = isDark ? AppColors.darkBg : AppColors.softBg;
    final Color cardColor = isDark ? AppColors.darkCard : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text('Trip History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading && _trips.isEmpty
          ? Center(child: CircularProgressIndicator(color: _neonTeal))
          : _trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 64, color: context.dynamicMuted.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('No past trips found.', style: TextStyle(color: context.dynamicMuted, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return _buildTripCard(trip, cardColor, textColor, context);
                  },
                ),
    );
  }

  Widget _buildTripCard(dynamic trip, Color cardColor, Color textColor, BuildContext context) {
    String dateText = trip['date'] ?? "Recent Ride"; 
    if (trip['timestamp'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(trip['timestamp']).toLocal();
        dateText = DateFormat('MMM d, yyyy • h:mm a').format(parsedDate);
      } catch (e) {
        dateText = "Unknown Date";
      }
    }

    String fareText = "₱0.00";
    if (trip['fare'] is num) {
      fareText = '₱${(trip['fare'] as num).toStringAsFixed(2)}';
    } else if (trip['fare'] != null) {
      fareText = trip['fare'].toString();
    }

    String origin = trip['origin'] ?? 'Unknown';
    String dest = trip['destination'] ?? 'Unknown';
    if (trip['origin'] == null && trip['route'] != null) {
      final parts = trip['route'].toString().split(' to ');
      if (parts.length == 2) {
        origin = parts[0];
        dest = parts[1];
      } else {
        origin = trip['route'];
      }
    }

    String status = trip['status'] ?? 'Completed';
    if (status.isNotEmpty) status = status[0].toUpperCase() + status.substring(1).toLowerCase();
    bool isCompleted = status == 'Completed';
    String driverName = trip['driver_name'] ?? trip['driver'] ?? 'Unknown Driver';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dynamicBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(dateText, style: TextStyle(color: context.dynamicMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(status, style: TextStyle(color: isCompleted ? Colors.green : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(fareText, style: const TextStyle(color: AppColors.neonTeal, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trip_origin, color: _neonTeal, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(origin, style: TextStyle(color: textColor, fontWeight: FontWeight.w600))),
            ],
          ),
          Container(margin: const EdgeInsets.only(left: 7), height: 12, width: 2, color: context.dynamicBorder),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(dest, style: TextStyle(color: textColor, fontWeight: FontWeight.w600))),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 12, backgroundColor: _deepOcean.withOpacity(0.1), child: Icon(Icons.person, size: 14, color: _deepOcean)),
                  const SizedBox(width: 8),
                  Text(driverName, style: TextStyle(color: context.dynamicMuted, fontSize: 12)),
                ],
              ),
              // THE RATING DIALOG BUTTON REPLACEMENT
              OutlinedButton(
                onPressed: () => _showRatingDialog(context, trip),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 30),
                  side: const BorderSide(color: AppColors.neonTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Rate Driver', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.neonTeal)),
              )
            ],
          )
        ],
      ),
    );
  }
}