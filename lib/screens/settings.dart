import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homespice/screens/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _isSaving = false;

  final _auth = FirebaseAuth.instance;

  // Validate current password with Firebase and update password
  Future<void> _changePassword() async {
    setState(() => _isSaving = true);

    final user = _auth.currentUser;
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (user == null || currentPassword.isEmpty || newPassword.isEmpty) {
      _showSnackbar("Please fill both fields");
      setState(() => _isSaving = false);
      return;
    }
    if (newPassword.length < 6) {
      _showSnackbar("New password must be at least 6 characters");
      setState(() => _isSaving = false);
      return;
    }
    if (currentPassword == newPassword) {
      _showSnackbar("New password must be different from current password");
      setState(() => _isSaving = false);
      return;
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$',
    ).hasMatch(newPassword)) {
      _showSnackbar(
        "New password must contain at least one uppercase letter, one lowercase letter, and one number",
      );
      setState(() => _isSaving = false);
      return;
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      // Re-authenticate
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
      _showSnackbar("Password changed successfully", isSuccess: true);
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? "Failed to change password");
    } catch (e) {
      _showSnackbar("An error occurred");
    }

    setState(() => _isSaving = false);
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  //delete account with re-authentication
  Future<void> deleteAccountWithReAuth(
    BuildContext context,
    String currentPassword,
  ) async {
    if (currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your current password.")),
      );
      return;
    }

    await deleteAccount(context, currentPassword);
  }

  Future<void> deleteAccount(
    BuildContext context,
    String currentPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No user logged in.")));
      }
      return;
    }

    try {
      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete user
      await user.delete();

      // Navigate and show success
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(this.context, '/login', (_) => false);
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'user-mismatch':
          errorMessage = "User credentials do not match.";
          break;
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'invalid-credential':
          errorMessage = "Invalid credentials. Please try again.";
          break;
        case 'requires-recent-login':
          errorMessage = "Please log in again to delete your account.";
          break;
        default:
          errorMessage = "Error: ${e.message}";
      }

      if (mounted) {
        ScaffoldMessenger.of(
          this.context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text("Unexpected error: ${e.toString()}")),
        );
      }
    }
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withAlpha((0.1 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 50),
            const Icon(Icons.settings, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: GoogleFonts.aBeeZee(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),

      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Change Password Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha((0.3 * 255).toInt()),
                          offset: const Offset(1,1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current Password
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: !_showCurrentPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your current password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showCurrentPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showCurrentPassword = !_showCurrentPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // New Password
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter a new password',
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showNewPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isSaving ? null : _changePassword,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon:
                          _isSaving
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Dark Mode Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode",style: TextStyle(fontSize: 18),),
                Switch(
                  value: isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Settings Card List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSettingsCard(
                  icon: Icons.privacy_tip,
                  title: "Privacy Policy",
                  onTap: () => Navigator.pushNamed(context, '/privacy'),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  icon: Icons.mode_edit_outline,
                  title: "Terms of Service",
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  icon: Icons.settings,
                  title: "App Version               1.0",
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  icon: Icons.logout,
                  title: "Delete Account",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Please enter your password to delete your account:",
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,

                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: "Password",
                                  hintText: "Enter Current Password....",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text("Delete"),
                              onPressed: () {
                                Navigator.of(context).pop(); // close dialog
                                deleteAccount(
                                  context,
                                  _passwordController.text,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
