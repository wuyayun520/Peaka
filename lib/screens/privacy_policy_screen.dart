import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Last Updated: March 15, 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'At Peaka, we take your privacy seriously. This Privacy Policy describes how we collect, use, and handle your personal information '
              'when you use our mobile application and services.\n\n'
              '1. Information We Collect\n\n'
              'We collect several types of information from and about users of our App:\n\n'
              'Personal Information:\n'
              '• Name and contact information (email address, phone number)\n'
              '• Profile information (age, location, interests)\n'
              '• Photos and videos you choose to share\n'
              '• Emergency contact information\n\n'
              'Usage Information:\n'
              '• Device information (device ID, operating system)\n'
              '• Log data (IP address, browser type)\n'
              '• Activity data (sports activities, locations)\n'
              '• Communication preferences\n\n'
              '2. How We Use Your Information\n\n'
              'We use the information we collect to:\n'
              '• Provide, maintain, and improve our services\n'
              '• Process your transactions and bookings\n'
              '• Send you technical notices and support messages\n'
              '• Communicate with you about products, services, and events\n'
              '• Analyze usage patterns and improve user experience\n'
              '• Ensure safety and security of our community\n'
              '• Comply with legal obligations\n\n'
              '3. Information Sharing and Disclosure\n\n'
              'We may share your information with:\n'
              '• Other users (as per your privacy settings)\n'
              '• Service providers and partners\n'
              '• Emergency services (when required)\n'
              '• Legal authorities (when required by law)\n\n'
              'We do not sell your personal information to third parties.\n\n'
              '4. Data Security\n\n'
              'We implement appropriate technical and organizational measures to protect your personal information, including:\n'
              '• Encryption of data in transit and at rest\n'
              '• Regular security assessments\n'
              '• Employee training on data protection\n'
              '• Secure data storage and processing\n\n'
              '5. Your Rights and Choices\n\n'
              'You have the right to:\n'
              '• Access your personal information\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Object to processing of your data\n'
              '• Export your data\n'
              '• Opt-out of marketing communications\n\n'
              '6. Data Retention\n\n'
              'We retain your information for as long as necessary to provide our services and comply with legal obligations. '
              'You can request deletion of your account at any time.\n\n'
              '7. Children\'s Privacy\n\n'
              'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13. '
              'If you become aware that a child has provided us with personal information, please contact us.\n\n'
              '8. International Data Transfers\n\n'
              'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards '
              'are in place for such transfers.\n\n'
              '9. Changes to This Policy\n\n'
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy '
              'on this page and updating the "Last Updated" date.\n\n'
              '10. Contact Us\n\n'
              'If you have any questions about this Privacy Policy or our practices, please contact us:\n\n'
              'Privacy Officer\n'
              'Peaka Inc.\n'
              'Email: privacy@peaka.com\n'
              'For urgent privacy concerns, we aim to respond within 24 hours.\n\n'
              '© 2025 Peaka. All rights reserved.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 