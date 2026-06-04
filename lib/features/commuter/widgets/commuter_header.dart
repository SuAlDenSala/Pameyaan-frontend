import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../screens/commuter_settings_screen.dart';
import '../../../core/theme/app_theme.dart';

class CommuterHeader extends StatelessWidget {
  final String fullName;
  final String initials;
  final String discountStatus;
  final Function(String) onProfileUpdated;

  const CommuterHeader({
    super.key,
    required this.fullName,
    required this.initials,
    required this.discountStatus,
    required this.onProfileUpdated,
  });

  final Color _deepOcean = AppColors.deepOcean;
  final Color _neonTeal = AppColors.neonTeal;
  final Color _softBg = AppColors.softBg;

  void _showEditProfileDialog(BuildContext context) {
    final nameEditController = TextEditingController(text: fullName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.edit_note, color: _deepOcean),
            const SizedBox(width: 8),
            Text('Edit Name', style: TextStyle(color: _deepOcean, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update your display name:', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: nameEditController,
              autofocus: true,
              style: TextStyle(color: _deepOcean, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: _softBg,
                prefixIcon: const Icon(Icons.person, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameEditController.text.trim().isNotEmpty) {
                onProfileUpdated(nameEditController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Name updated locally!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    backgroundColor: _deepOcean,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _deepOcean,
              foregroundColor: _neonTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBoardingPassQR(BuildContext context) {
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
                backgroundColor: _deepOcean.withOpacity(0.1),
                child: Text(initials, style: TextStyle(color: _deepOcean, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              const SizedBox(height: 16),
              Text(fullName, style: TextStyle(color: _deepOcean, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _neonTeal.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(discountStatus, style: TextStyle(color: Colors.teal[800], fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              QrImageView(data: 'COMMUTER:$fullName|$discountStatus', version: QrVersions.auto, size: 200.0, foregroundColor: _deepOcean),
              const SizedBox(height: 12),
              const Text('Show this to the driver for scanning', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          InkWell(
            onTap: () async {
              final updatedName = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommuterSettingsScreen(fullName: fullName, initials: initials, discountStatus: discountStatus)),
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
                    backgroundColor: Colors.white,
                    child: Text(initials, style: TextStyle(color: _deepOcean, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Where to today,', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      Row(
                        children: [
                          Text('$fullName?', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showEditProfileDialog(context),
                            child: Icon(Icons.edit, color: Colors.white.withOpacity(0.5), size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _neonTeal.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: _neonTeal.withOpacity(0.5))),
                        child: Text(discountStatus, style: TextStyle(color: _neonTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.sync, color: _neonTeal, size: 16),
                    const SizedBox(width: 4),
                    const Text('Synced', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28), onPressed: () => _showBoardingPassQR(context)),
            ],
          ),
        ],
      ),
    );
  }
}