import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../../core/theme/app_theme.dart';
import '../screens/driver_settings_screen.dart'; 

class DriverHeader extends StatelessWidget {
  final String driverName;
  final String initials;
  final String franchiseNumber;
  final double communityTrustScore;
  final int totalRatings;
  final Function(String) onProfileUpdated; 

  const DriverHeader({
    super.key,
    required this.driverName,
    required this.initials,
    required this.franchiseNumber,
    required this.communityTrustScore,
    required this.totalRatings,
    required this.onProfileUpdated, 
  });

  final Color _deepOcean = AppColors.deepOcean;
  final Color _neonTeal = AppColors.neonTeal;

  void _showDriverQR(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String qrHash = prefs.getString('driver_qr_hash') ?? '';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: _deepOcean.withValues(alpha: 0.1),
                child: Text(initials, style: TextStyle(color: _deepOcean, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              const SizedBox(height: 16),
              Text(driverName, style: TextStyle(color: _deepOcean, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _neonTeal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('Franchise: $franchiseNumber', style: TextStyle(color: Colors.teal[800], fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              
              if (qrHash.isNotEmpty)
                QrImageView(
                  data: qrHash, 
                  version: QrVersions.auto, 
                  size: 200.0, 
                  foregroundColor: _deepOcean
                )
              else 
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "QR Code Unavailable.\nPlease log out and log back in to sync your profile.", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.redAccent)
                  ),
                ),
                
              const SizedBox(height: 12),
              const Text('Commuters can scan this to log their ride', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('CLOSE', style: TextStyle(color: _neonTeal, fontWeight: FontWeight.bold, letterSpacing: 1))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final updatedName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverSettingsScreen(
                      driverName: driverName,
                      initials: initials,
                      franchiseNumber: franchiseNumber,
                    ),
                  ),
                );
                
                if (updatedName != null && updatedName is String) {
                  onProfileUpdated(updatedName);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: context.isDarkMode ? Colors.white : AppColors.deepOcean,
                      child: Text(initials, style: TextStyle(color: context.isDarkMode ? AppColors.deepOcean : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('On Duty,', style: TextStyle(color: context.dynamicMuted, fontSize: 12)),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  driverName, 
                                  style: TextStyle(color: context.dynamicText, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                communityTrustScore > 0 ? communityTrustScore.toStringAsFixed(1) : 'New',
                                style: TextStyle(color: context.dynamicText, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($totalRatings reviews)',
                                style: TextStyle(color: context.dynamicMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.neonTeal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.5))),
                            child: Text(franchiseNumber, style: TextStyle(color: context.isDarkMode ? AppColors.neonTeal : Colors.teal[800], fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), 
          IconButton(icon: Icon(Icons.qr_code, color: context.dynamicText, size: 28), onPressed: () => _showDriverQR(context)),
        ],
      ),
    );
  }
}