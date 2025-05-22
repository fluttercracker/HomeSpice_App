import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
        final TextStyle _headerStyle = const TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  height: 2,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user_outlined, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Privacy Policy',
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

      body: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
        children: [
          const SizedBox(height: 20),
           const Text('Effective Date: May 2, 2025\n', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

              Text('1. Introduction', style: _headerStyle),
              const Text(
                'Welcome to Food Recipe App ("we", "our", or "us"). Your privacy is important to us. '
                'This Privacy Policy explains how we collect, use, and protect your information when you use our app.\n',
              ),

              Text('2. Information We Collect', style: _headerStyle),
              const Text(
                'We may collect the following types of information:\n\n'
                '- Personal Information: Name, email address, profile picture (when signing in using Google or other login providers).\n'
                '- Usage Data: Recipes viewed, liked, or saved.\n'
                '- Device Information: Device type, OS version, and app version.\n\n'
                'We use Firebase Authentication and Firebase Analytics to help us manage this data securely.\n',
              ),

              Text('3. How We Use Your Information', style: _headerStyle),
              const Text(
                'We use your information to:\n'
                '- Allow you to log in and manage your profile\n'
                '- Provide personalized recipe recommendations\n'
                '- Improve the user experience and fix bugs\n'
                '- Understand how users interact with our app\n',
              ),

              Text('4. Sharing Your Information', style: _headerStyle),
              const Text(
                'We do not sell or rent your personal information. We only share data with:\n'
                '- Firebase (Google LLC), to authenticate users and analyze app performance\n'
                '- Other third-party services only when necessary for app functionality\n',
              ),

              Text('5. Data Security', style: _headerStyle),
              const Text(
                'We use modern security practices to protect your data, including encryption and secure authentication methods. '
                'However, no method of data transmission is 100% secure.\n',
              ),

              Text('6. Your Rights', style: _headerStyle),
              const Text(
                'You can:\n'
                '- Access or update your account information\n'
                '- Request deletion of your data by contacting us\n'
                '- Withdraw consent for data usage (may affect app functionality)\n',
              ),

              Text('7. Children’s Privacy', style: _headerStyle),
              const Text(
                'Our app is not intended for children under 13. '
                'We do not knowingly collect personal information from children without parental consent.\n',
              ),

              Text('8. Changes to This Policy', style: _headerStyle),
              const Text(
                'We may update this Privacy Policy from time to time. Any changes will be posted here with the updated effective date.\n',
              ),

              Text('9. Contact Us', style: _headerStyle),
              const Text(
                'If you have any questions about this Privacy Policy, you can contact us at:\n\n'
                'Email: support@foodrecipeapp.com\n'
                'Address: Your Company Name, City, Country\n',
              ),
        ],
      ),
      ),
      ),

    );
  }
}
