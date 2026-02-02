import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'General'),
              _buildListTile(
                context,
                title: 'Theme Mode',
                subtitle: _getThemeModeString(settings.themeMode),
                icon: Icons.brightness_6_rounded,
                onTap: () => _showThemeDialog(context, settings),
              ),
              _buildSwitchTile(
                context,
                title: 'Notification New Status',
                subtitle: 'Get notified when new statuses available',
                icon: Icons.notifications_active_rounded,
                value: settings.notificationsActive,
                onChanged: (value) => settings.setNotificationsActive(value),
              ),
              _buildSwitchTile(
                context,
                title: 'Auto Save',
                subtitle: 'Automatically Save all New Statuses',
                icon: Icons.auto_awesome_rounded,
                value: settings.autoSaveActive,
                onChanged: (value) => settings.setAutoSaveActive(value),
              ),
              _buildListTile(
                context,
                title: 'Save Statuses in Folder',
                subtitle: '/Internal Storage/Pictures/StatusSaver',
                icon: Icons.folder_rounded,
                onTap: () {
                  // This is informative as per FileService.getSaveDirectory() logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Statuses are saved in Pictures/StatusSaver',
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Help & Support'),
              _buildListTile(
                context,
                title: 'How to use',
                subtitle: 'Know how to use this app to download statuses',
                icon: Icons.help_outline_rounded,
                onTap: () => _showHowToUse(context),
              ),
              _buildListTile(
                context,
                title: 'Privacy policy',
                subtitle: 'Our Terms and conditions',
                icon: Icons.privacy_tip_rounded,
                onTap: () => _launchURL('https://example.com/privacy'),
              ),
              _buildListTile(
                context,
                title: 'Share with others',
                subtitle: 'Share this app with your beloved friends',
                icon: Icons.share_rounded,
                onTap: () =>
                    Share.share('Check out this WhatsApp Status Saver app!'),
              ),
              _buildListTile(
                context,
                title: 'Rate us',
                subtitle: 'Please support our work by your rating',
                icon: Icons.star_rate_rounded,
                onTap: () => _launchURL(
                  'https://play.google.com/store/apps/details?id=com.example.wa_status_saver',
                ),
              ),
              const Divider(),
              _buildSectionHeader(context, 'About'),
              _buildListTile(
                context,
                title: 'About',
                subtitle: 'Version: 1.0.0+1',
                icon: Icons.info_outline_rounded,
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Status Saver',
                  applicationVersion: '1.0.0+1',
                  applicationIcon: const Icon(
                    Icons.download_rounded,
                    size: 48,
                    color: Color(0xFF25D366),
                  ),
                  children: [
                    const Text(
                      'Beautifully designed WhatsApp Status Saver for your daily needs.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF25D366),
    );
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              settings,
              ThemeMode.system,
              'System Default',
            ),
            _buildThemeOption(context, settings, ThemeMode.light, 'Light Mode'),
            _buildThemeOption(context, settings, ThemeMode.dark, 'Dark Mode'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsProvider settings,
    ThemeMode mode,
    String label,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
      groupValue: settings.themeMode,
      onChanged: (value) {
        if (value != null) {
          settings.setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _showHowToUse(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Open WhatsApp or WhatsApp Business.'),
            Text('2. View the status you want to save.'),
            Text('3. Open this Status Saver app.'),
            Text('4. Find the status and click the save icon.'),
            Text('5. View saved statuses in the "Saved" tab.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }
}
