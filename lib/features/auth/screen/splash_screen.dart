import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection_screen.dart';
import '../../driver/screens/driver_dashboard_screen.dart';
import '../../commuter/screens/commuter_app_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Color _brandDark = const Color(0xFF0F172A);
  final Color _bgLight = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    
    // 1. FASTER: Reduced animation time to 800 milliseconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _checkLoginState();
  }

  void _checkLoginState() async {
    // Check if user is logged in
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('offline_id');
    final isDriver = prefs.getBool('offline_isDriver') ?? false;
    final savedName = prefs.getString('offline_name') ?? '';

    // Still wait at least 1.5 seconds so the splash animation finishes
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (savedId != null && savedId.isNotEmpty) {
      String extractedName = savedName;
      if (extractedName.isEmpty) {
        extractedName = savedId.contains('@') ? savedId.split('@')[0] : savedId;
        if (extractedName.isNotEmpty) {
          extractedName = extractedName[0].toUpperCase() + extractedName.substring(1).toLowerCase();
        } else {
          extractedName = isDriver ? "Driver" : "Commuter";
        }
      }

      String userInitials = extractedName.isNotEmpty ? extractedName[0].toUpperCase() : (isDriver ? 'D' : 'C');
      String formatId = isDriver ? savedId.toUpperCase() : 'UNKNOWN-ID';

      if (isDriver) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DriverDashboardScreen(
            driverName: extractedName,
            initials: userInitials,
            franchiseNumber: formatId
          )),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CommuterAppScreen(
            fullName: extractedName,
            initials: userInitials,
            discountStatus: 'Regular',
            email: savedId
          )),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3. LOGO FIX: Swapped to a boat, or replace with Image.asset
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _brandDark.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: Icon(Icons.directions_boat_filled, size: 90, color: _brandDark),
                ),
                const SizedBox(height: 32),
                
                // 4. NAME FIX: Updated to Pemeyaan
                Text(
                  'Pemeyaan',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: _brandDark,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tawi-Tawi Transport & Logistics',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}