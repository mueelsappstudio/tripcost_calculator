import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../providers/calculator_provider.dart';
import 'legal_screen.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Guest User";
      if (_userName.isEmpty) _userName = "Guest User";
    });
  }

  // This is the POPUP logic
  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final provider = Provider.of<CalculatorProvider>(context, listen: false);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Currency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              _currencyOption(context, provider, "PKR (Rs)", "Rs"),
              _currencyOption(context, provider, "USD (\$)", "\$"),
              _currencyOption(context, provider, "EUR (€)", "€"),
              _currencyOption(context, provider, "GBP (£)", "£"),
              _currencyOption(context, provider, "INR (₹)", "₹"),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _currencyOption(BuildContext context, CalculatorProvider provider, String label, String symbol) {
    return ListTile(
      title: Text(label),
      leading: const Icon(Icons.monetization_on_outlined, color: AppColors.textSecondary),
      onTap: () {
        provider.setCurrency(symbol);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("General"),
          _buildTile(context, Icons.person, "Profile", _userName, onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            _loadUserData();
          }),

          // Currency Tile (This opens the popup now)
          _buildTile(context, Icons.currency_exchange, "Currency", provider.currencySymbol, onTap: () {
            _showCurrencyPicker(context);
          }),

          const SizedBox(height: 20),
          _buildSectionHeader("Preferences"),

          // Notifications Switch
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
            ),
            child: SwitchListTile(
              activeColor: AppColors.primary,
              title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.notifications, color: AppColors.textMain, size: 20),
              ),
              value: provider.notificationsEnabled,
              onChanged: (bool value) {
                provider.toggleNotifications(value);
              },
            ),
          ),

          _buildTile(context, Icons.privacy_tip, "Privacy Policy", "", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(
              title: "Privacy Policy",
              content: '''
Last Updated: November 2025

1. Data Collection
TripCost Calculator operates primarily as an offline utility. We do not store your personal data, trip history, or vehicle settings on external servers. All data is stored locally on your device using Shared Preferences.

2. Permissions
- Internet Access: Required for displaying advertisements (Google AdMob) and loading external resources.
- Storage/Media: Required only if you choose to save or export trip reports locally.

3. Third-Party Services
We use Google AdMob to display advertisements. Google may use device identifiers to personalize content and ads. By using this app, you consent to Google's data collection policy regarding advertisements.

4. User Profile
Your name and phone number entered in the "Profile" section are stored strictly on your device to personalize your experience. We do not have access to this information.

5. Data Deletion
Since data is stored locally, simply uninstalling the application will permanently remove all your saved trips and settings.
''',
            )));
          }),

          _buildTile(context, Icons.description, "Terms & Conditions", "", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(
              title: "Terms & Conditions",
              content: '''
1. Acceptance of Terms
By downloading or using TripCost Calculator, you agree to these terms. If you do not agree, please do not use the application.

2. Accuracy of Estimates
This application provides ESTIMATED costs based on the data you input (fuel price, average, distance). Actual trip costs may vary due to traffic, driving style, road conditions, and vehicle health. 

3. Liability Disclaimer
The developer of TripCost Calculator is not liable for any financial losses, disputes, or damages resulting from the use of these calculations. You use this tool at your own risk.

4. Intellectual Property
You may not copy, modify, or distribute the source code or design of this application without explicit permission.

5. Modifications
We reserve the right to update these terms or the application features at any time without prior notice.
''',
            )));
          }),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text("Log Out"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade100)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String value, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.textMain, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.isNotEmpty) Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            if (value.isNotEmpty) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}