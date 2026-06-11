import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; 
import '../../../core/network/api_client.dart'; 
import '../screens/commuter_settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'rating_modal.dart';

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
                      backgroundColor: context.isDarkMode ? Colors.white : AppColors.deepOcean,
                      child: Text(initials, style: TextStyle(color: context.isDarkMode ? AppColors.deepOcean : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Where to today,', style: TextStyle(color: context.dynamicMuted, fontSize: 12)),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  fullName,
                                  style: TextStyle(color: context.dynamicText, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: _neonTeal.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: _neonTeal.withOpacity(0.5))),
                            child: Text(discountStatus, style: TextStyle(color: context.isDarkMode ? _neonTeal : Colors.teal[800], fontSize: 10, fontWeight: FontWeight.bold)),
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
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: context.dynamicText, size: 28), 
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const CommuterQRScannerScreen())
            ),
          ),
        ],
      ),
    );
  }
}

class CommuterQRScannerScreen extends StatefulWidget {
  const CommuterQRScannerScreen({super.key});

  @override
  State<CommuterQRScannerScreen> createState() => _CommuterQRScannerScreenState();
}

class _CommuterQRScannerScreenState extends State<CommuterQRScannerScreen> {
  bool _isProcessing = false;
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isProcessing = true);
      _scannerController.stop(); // Pause camera to prevent memory crash
      
      final String scannedString = barcodes.first.rawValue!;

      try {
        final response = await ApiClient.instance.get('/drivers/profile/$scannedString');
        
        if (response.statusCode == 200) {
          final data = response.data;
          if (!mounted) return;
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => RatingModal(
              driverId: data['driver_id'] ?? data['id'] ?? scannedString,
              driverName: data['name'] ?? 'Unknown Driver',
              franchiseNumber: data['tricycle_body_number'] ?? 'N/A',
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR Code or Unregistered Driver.'), backgroundColor: Colors.redAccent),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isProcessing = false);
            _scannerController.start();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Driver QR'), backgroundColor: AppColors.deepOcean, foregroundColor: Colors.white),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController, 
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.neonTeal),
                    SizedBox(height: 16),
                    Text('Verifying community profile...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}