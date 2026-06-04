import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../auth/screen/role_selection_screen.dart';
import 'driver_edit_profile_screen.dart'; // <-- IMPORT THE NEW SCREEN

class DriverSettingsScreen extends StatefulWidget {
  final String driverName;
  final String initials;
  final String franchiseNumber;

  const DriverSettingsScreen({
    super.key,
    required this.driverName,
    required this.initials,
    required this.franchiseNumber,
  });

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  // State variables so the UI can update instantly
  late String _currentName;
  late String _currentInitials;

  final Color _deepOcean = const Color(0xFF0B192C);
  final Color _neonTeal = const Color(0xFF00FFCA);
  final Color _softBg = const Color(0xFFF4F7F9);

  @override
  void initState() {
    super.initState();
    _currentName = widget.driverName;
    _currentInitials = widget.initials;
  }

  void _handleLogout(BuildContext context) {
    ApiClient.instance.options.headers.remove('Authorization');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false, 
    );
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
        title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48, 
                  backgroundColor: _deepOcean.withOpacity(0.1), 
                  child: Text(_currentInitials, style: TextStyle(color: _deepOcean, fontSize: 36, fontWeight: FontWeight.bold))
                ),
                const SizedBox(height: 16),
                Text(_currentName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _deepOcean)),
                const SizedBox(height: 4),
                Text('Operator ID: ${widget.franchiseNumber}', style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          const Text('PREFERENCES', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          
          // --- UPDATED EDIT PROFILE BUTTON ---
          _buildSettingsTile(context, Icons.person_outline, 'Edit Profile', onTap: () async {
            // Wait for the new name to come back from the Edit Screen
            final updatedName = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverEditProfileScreen(
                  currentName: _currentName,
                  franchiseNumber: widget.franchiseNumber,
                ),
              ),
            );
            
            // Instantly update the UI if they saved a new name
            if (updatedName != null && updatedName is String) {
              setState(() {
                _currentName = updatedName;
                _currentInitials = updatedName.isNotEmpty ? updatedName[0].toUpperCase() : 'D';
              });
            }
          }),

          _buildSettingsTile(context, Icons.lock_outline, 'Change Password'),
          _buildSettingsTile(context, Icons.language, 'Language (English)'),
          
          const SizedBox(height: 24),
          const Text('SYSTEM', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),

          _buildSettingsTile(context, Icons.info_outline, 'About Platform'),
          _buildSettingsTile(context, Icons.help_outline, 'Help & Support'),

          const SizedBox(height: 40),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.logout, color: Colors.redAccent)),
            title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // UPDATED: Now accepts an optional onTap function
  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.white,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _softBg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: _deepOcean, size: 20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: _deepOcean, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title coming soon.'), backgroundColor: _neonTeal, behavior: SnackBarBehavior.floating));
        },
      ),
    );
  }
}