import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.rule, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Terms and Conditions',
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

      
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Effective Date: May 2, 2025\n', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

              Text('1. Acceptance of Terms', style: _headerStyle),
              Text(
                'By accessing or using the Food Recipe App ("the App"), you agree to be bound by these Terms and Conditions and our Privacy Policy.\n',
              ),

              Text('2. Use of the App', style: _headerStyle),
              Text(
                'You may use the App for personal, non-commercial purposes only. You agree not to misuse the services, share offensive content, or attempt to disrupt app functionality.\n',
              ),

              Text('3. User Accounts', style: _headerStyle),
              Text(
                'You are responsible for maintaining the confidentiality of your login information and for all activities that occur under your account.\n',
              ),

              Text('4. Intellectual Property', style: _headerStyle),
              Text(
                'All content provided by the App—including recipes, images, and branding—is the property of the App or its content creators.\n',
              ),

              Text('5. Limitation of Liability', style: _headerStyle),
              Text(
                'We do our best to provide accurate and helpful information. However, we are not liable for any health issues, injuries, or losses resulting from the use of recipes or content in the app.\n',
              ),

              Text('6. Modifications', style: _headerStyle),
              Text(
                'We reserve the right to update or modify these Terms at any time. Changes will be effective upon posting in the app.\n',
              ),

              Text('7. Termination', style: _headerStyle),
              Text(
                'We reserve the right to terminate or suspend your access if you violate these Terms.\n',
              ),

              Text('8. Contact Us', style: _headerStyle),
              Text(
                'For questions about these Terms, contact:\n\n'
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

const TextStyle _headerStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  height: 2,
);
