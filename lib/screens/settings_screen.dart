import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              // Settings Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: const Color(0xFF25D366),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Theme Selection
              _buildSettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: _getThemeModeText(settings.themeMode),
                onTap: () => _showThemeDialog(context, settings),
              ),

              const Divider(height: 1),

              // How to use
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'How to use',
                subtitle: 'Know how to use this app to download statuses',
                onTap: () => _showHowToUseDialog(context),
              ),

              const Divider(height: 1),

              // Notification toggle
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Notification New Status',
                subtitle: 'Get notified when new statuses available',
                value: settings.notifications,
                onChanged: (value) => settings.setNotifications(value),
              ),

              const Divider(height: 1),

              // Auto Save toggle
              _buildSwitchTile(
                icon: Icons.save_alt_rounded,
                title: 'Auto Save',
                subtitle: 'Automatically Save all New Statuses',
                value: settings.autoSave,
                onChanged: (value) => settings.setAutoSave(value),
              ),

              const Divider(height: 1),

              // Save folder
              _buildSettingsTile(
                icon: Icons.folder_outlined,
                title: 'Save Statuses in Folder',
                subtitle: '/storage/emulated/0/Download/WAStatusSaver',
                onTap: null,
              ),

              const Divider(height: 1),

              // Privacy Policy
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy policy',
                subtitle: 'Our Terms and conditions',
                onTap: () => _launchUrl('https://example.com/privacy'),
              ),

              const Divider(height: 1),

              // Share with others
              _buildSettingsTile(
                icon: Icons.share_outlined,
                title: 'Share with others',
                subtitle: 'Share this app with your beloved friends',
                onTap: () => _shareApp(),
              ),

              const Divider(height: 1),

              // Rate us
              _buildSettingsTile(
                icon: Icons.star_outline_rounded,
                title: 'Rate us',
                subtitle: 'Please support our work by your rating',
                onTap: () => _rateApp(),
              ),

              const Divider(height: 1),

              // About
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version: $_appVersion',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: const Color(0xFF25D366),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: const Color(0xFF25D366),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System default'),
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: const Color(0xFF25D366),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHowToUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Use'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1. Open WhatsApp and view the statuses you want to save.\n\n'
                  '2. Come back to Status Saver - the viewed statuses will appear automatically.\n\n'
                  '3. Tap on any status to preview it.\n\n'
                  '4. Use the download button to save the status to your device.\n\n'
                  '5. Saved statuses can be found in the "Saved" tab.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it',
                style: TextStyle(color: Color(0xFF25D366)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Status Saver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: $_appVersion'),
              const SizedBox(height: 16),
              const Text(
                'Status Saver helps you save and share WhatsApp statuses with ease. '
                'Simply view a status on WhatsApp, and it will appear here for you to save.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _launchUrl('https://achendo.com'),
                child: const Text(
                  'Developed by achendo.com',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF25D366),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF25D366),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Achendo Agency, we are a Creative Tech Agency with expertise in social media management, digital marketing, branding, and software development.',
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF25D366)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    Share.share(
      'Check out Status Saver - the best app to save WhatsApp statuses! '
      'Download now: https://play.google.com/store/apps/details?id=com.example.wa_status_saver',
      subject: 'Status Saver App',
    );
  }

  Future<void> _rateApp() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.example.wa_status_saver';
    await _launchUrl(url);
  }
}
