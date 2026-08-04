import 'package:flutter/material.dart';
import 'package:quiz_zee/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.12),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'My Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              _ProfileMenuItem(icon: Icons.home, label: 'Home', onTap: () {  },),
              _ProfileMenuItem(icon: Icons.menu_book, label: 'Subject Wise Test', onTap: () {  },),
              _ProfileMenuItem(icon: Icons.book_outlined, label: 'Books', onTap: () {  },),
              //_ProfileMenuItem(icon: Icons.announcement_outlined, label: 'Announcements'),
              _ProfileMenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {  },),
              _ProfileMenuItem(icon: Icons.star_border, label: 'Rate Us', onTap: () {  },),
              _ProfileMenuItem(icon: Icons.share, label: 'Share App', onTap: () {  },),
              //_ProfileMenuItem(icon: Icons.settings, label: 'Setting'),
              _ProfileMenuItem(icon: Icons.logout, label: 'Log out', onTap: () {
                _logout(context);
              },),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data (or use remove('token') if you only want to remove token)
    Navigator.pushNamedAndRemoveUntil(context, '/loginScreen', (route) => false);
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final GestureTapCallback onTap;
  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 28),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: FlutterFlowTheme.of(context).primaryText,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,size: 15,),
          ],
        ),
      ),
    );
  }
} 
