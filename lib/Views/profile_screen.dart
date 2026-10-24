import 'package:flutter/material.dart';
import 'package:mass_ledger/ViewModel/ledger_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';

const Color _navy = Color(0xFF09275F);

// ================================================================
// PROFILE SCREEN
// ================================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LedgerViewModel>();
    final profile = vm.profile;

    final initial = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim()[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ====================================================
            // MENU
            // ====================================================

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _tile(
                    icon: Icons.person_outline,
                    title: 'Account Settings',
                    onTap: () => _editName(context, vm),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.lock_outline,
                    title: 'Security',
                    onTap: () => _changePassword(context),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => _comingSoon(context),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.attach_money,
                    title: 'Currency',
                    trailingText: profile.currency,
                    onTap: null,
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _comingSoon(context),
                  ),
                  _divider(),
                  _tile(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // WIDGET HELPERS
  // ==============================================================

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    String? trailingText,
    Color color = Colors.black87,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color == Colors.red ? color : _navy),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            )
          : onTap == null || color == Colors.red
              ? null
              : const Icon(Icons.chevron_right, color: Colors.black38),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon.')),
    );
  }

  // ==============================================================
  // EDIT NAME
  // ==============================================================

  void _editName(BuildContext context, LedgerViewModel vm) {
    final controller = TextEditingController(text: vm.profile.name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Account Settings'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);
                vm.updateProfile(name: name);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  // ==============================================================
  // CHANGE PASSWORD
  // ==============================================================

  void _changePassword(BuildContext context) {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = controller.text;

                if (password.length < 6) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password must be at least 6 characters.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  await Supabase.instance.client.auth.updateUser(
                    UserAttributes(password: password),
                  );

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Password updated.')),
                  );
                } on AuthException catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Unable to update password: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  // ==============================================================
  // LOGOUT
  // ==============================================================

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);

    await Supabase.instance.client.auth.signOut();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
