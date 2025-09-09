// lib/pages/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../managers/profile_manager.dart';
import '../../managers/color_manager.dart';
import '../../widgets/refer_and_earn_msg.dart';
import '../../widgets/theme_mode_toggle.dart';
import 'profile_your_account_details.dart';
import 'edit_profile_page.dart';
import 'contact_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'ADIL MUSHTAQ RATHER';
  String _phone = '9622424392';
  String _email = 'xyz@koshurkart.com';
  String _dob = '01/01/1990';

  static const _uniqueId = 'M701';
  static const _referralCode = 'KSK-REF-1234';

  Future<void> _editProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.of(context).push<ProfileUpdate>(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialName: _name,
          initialPhone: _phone,
          initialEmail: _email,
          initialDob: _dob,
        ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _name = result.name;
      _phone = result.phone;
      _email = result.email;
      _dob = result.dob;
    });
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pm = context.read<ProfileManager>();
    final colorMgr = context.watch<ColorManager>();

    final accent = colorMgr.currentMaterialColor.shade500;
    final isAccentLight = accent.computeLuminance() > 0.5;
    final barIcons = isAccentLight ? Brightness.dark : Brightness.light;
    final appBarText = isAccentLight ? Colors.black : Colors.white;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: accent,
        statusBarIconBrightness: barIcons,
        systemNavigationBarColor: Theme.of(context).canvasColor,
        systemNavigationBarIconBrightness:
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        iconTheme: IconThemeData(color: appBarText),
        title: Text('Profile', style: TextStyle(color: appBarText)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ThemeModeToggle(width: 52, height: 26),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileYourAccountDetails(
            name: _name,
            phone: _phone,
            email: _email,
            dob: _dob,
            uniqueId: _uniqueId,
            onTap: _editProfile,
            onUniqueTap: () {},
          ),
          const SizedBox(height: 16),

          // Referral banner…
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => showReferAndEarnMsgDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  accent.red,
                  accent.green,
                  accent.blue,
                  0.1,
                ),
                border: Border.all(color: accent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Referral Code: $_referralCode',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: accent),
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: _referralCode),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Referral code copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Section 1…
          Text('Section 1', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _menuTile(Icons.favorite_border, 'Your Wishlist', () {}),
          _menuTile(Icons.shopping_bag, 'Your Orders', () {}),
          _menuTile(Icons.book, 'Recipes', () {}),

          const SizedBox(height: 32),
          // Section 2…
          Text('Section 2', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _menuTile(Icons.receipt_long, 'GST Details', () {}),
          _menuTile(Icons.history, 'Address History', () {}),
          _menuTile(Icons.card_giftcard, 'E-Gifts', () {}),
          _menuTile(Icons.support_agent, 'Help & Support', () {}),

          const SizedBox(height: 32),
          // Section 3…
          Text('Section 3', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _menuTile(Icons.store, 'Sell with Us', () {}),
          _menuTile(Icons.work, 'Get a Job', () {}),
          _menuTile(Icons.account_balance_wallet, 'Wallet', () {}),
          _menuTile(Icons.credit_card, 'Card Save', () {}),
          _menuTile(Icons.emoji_events, 'Rewards', () {}),
          _menuTile(Icons.local_offer, 'Coupons', () {}),
          _menuTile(Icons.volunteer_activism, 'Donate', () {}),

          const SizedBox(height: 32),
          // Section 4…
          Text('Section 4', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _menuTile(Icons.notifications, 'Notifications', () {}),
          _menuTile(Icons.share, 'Share the App', () {
            showReferAndEarnMsgDialog(context);
          }),
          // ← NEW Contact Us tile
          _menuTile(Icons.contact_mail, 'Contact Us', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactPage()),
            );
          }),

          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await pm.logOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}