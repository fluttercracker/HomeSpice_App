import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homespice/screens/app_theme.dart';
import 'package:homespice/screens/theme_notifier.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AppTheme _selectedTheme = AppTheme.System;
  @override
  Widget build(BuildContext context) {
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

      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            'Change Password',
            style: GoogleFonts.aBeeZee(
              fontSize: 18,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 320,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter your current password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          SizedBox(
            width: 320,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter a new password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ),
          ),

          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              // Add your save onPressed code here!
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('    Change Theme:', style: TextStyle(fontSize: 16)),
              PopupMenuButton<AppTheme>(
                onSelected: (theme) {
                  setState(() => _selectedTheme = theme);
                  Provider.of<ThemeNotifier>(
                    context,
                    listen: false,
                  ).setTheme(theme);
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: AppTheme.Light,
                        child: Text('Light'),
                      ),
                      const PopupMenuItem(
                        value: AppTheme.Dark,
                        child: Text('Dark'),
                      ),
                      const PopupMenuItem(
                        value: AppTheme.System,
                        child: Text('System Default'),
                      ),
                    ],
                child: Row(
                  children: [
                    Text(_selectedTheme.name),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Privacy Policy"),
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(Icons.mode_edit_outline),
                  title: const Text("Terms of Service"),
                  onTap: () {
                    Navigator.pushNamed(context, '/terms');
                  },
                ),


                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("App Version               1.0"),
                  onTap: () {},
                ),


                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Delete Account"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text(
                            "Are you sure you want to delete your account? This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: const Text("Yes, Delete"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                //  Add delete logic here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Account deleted"),
                                  ),
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
        ],
      ),
    );
  }
}
