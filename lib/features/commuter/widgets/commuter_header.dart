import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; 
import '../../../core/network/api_client.dart'; 
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

// ==========================================
// MEMORY-SAFE QR SCANNER SCREEN
// ==========================================
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
    // Initialize the controller to manage camera memory
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    // MUST DISPOSE to prevent Android from crashing when you close the scanner
    _scannerController.dispose();
    super.dispose();
  }

 void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isProcessing = true);
      _scannerController.pause();
      
      final String scannedString = barcodes.first.rawValue!;

      // ========================================================
      // PRO-DEV X-RAY LOGS: STEP 1 & 2 (WHAT DID WE SCAN?)
      // ========================================================
      print('\n\n====== PRO-DEV DEBUGGING ======');
      print('1. THE SCANNER READ THIS EXACT STRING: "$scannedString"');
      print('2. ATTEMPTING NETWORK REQUEST TO: /drivers/profile/$scannedString');

      try {
        final response = await ApiClient.instance.get('/drivers/profile/$scannedString');
        
        print('3. SUCCESS! BACKEND RETURNED DATA: ${response.data}');
        print('===============================\n\n');
        
        if (response.statusCode == 200) {
          final data = response.data;
          if (!mounted) return;
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(data['is_lgu_verified'] ? Icons.verified : Icons.people, color: AppColors.neonTeal),
                  const SizedBox(width: 8),
                  const Text('Driver Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${data['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Tricycle Number: ${data['tricycle_body_number']}'),
                  const Divider(),
                  Text('Community Trust Score:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text('${data['community_trust_score']} / 5.0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('Based on ${data['total_ratings']} ratings', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonTeal),
                  onPressed: () async {
                    try {
                      await ApiClient.instance.post(
                        '/commuters/me/trips',
                        data: {
                          "franchise_number": data['tricycle_body_number'],
                          "origin": "Scanned Location", 
                          "destination": "Commuter Drop-off",
                          "fare": 20.0 
                        },
                      );
                      
                      if (!mounted) return;
                      Navigator.pop(context);
                      Navigator.pop(context); 
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trip logged to your history!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to log trip.'), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text('Log this Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // ========================================================
        // PRO-DEV X-RAY LOGS: STEP 3 (WHY DID IT FAIL?)
        // ========================================================
        print('3. ERROR! NETWORK REQUEST FAILED!');
        print('   REASON: ${e.toString()}');
        
        // If you are using Dio (which you are), we can extract the exact server response
        if (e.toString().contains('DioException')) {
           final dioError = e as dynamic; 
           print('   STATUS CODE: ${dioError.response?.statusCode}');
           print('   SERVER SAID: ${dioError.response?.data}');
           print('   FULL URL TRIED: ${dioError.requestOptions.uri}');
        }
        print('===============================\n\n');

        if (!mounted) return;
        
        // Temporary: Show the actual error on the screen so you don't have to look at the terminal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DEV ERROR: ${e.toString().split('\n').first}'), 
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
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
            controller: _scannerController, // Attached the memory controller here
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