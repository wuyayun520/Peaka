import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Terms of Service',
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
              '1. Acceptance of Terms\n\n'
              'By accessing and using the Peaka app ("the App"), you agree to be bound by these Terms of Service ("Terms"). '
              'If you do not agree to these terms, please do not use the app. Peaka reserves the right to modify these terms at any time, '
              'and such modifications shall be effective immediately upon posting.\n\n'
              '2. Use of Service\n\n'
              'You agree to use the service only for lawful purposes and in accordance with these Terms. You are responsible for:\n'
              '• All activity that occurs under your account\n'
              '• Maintaining the confidentiality of your account information\n'
              '• Providing accurate and current registration information\n'
              '• Ensuring that you exit from your account at the end of each session\n\n'
              '3. User Content and Conduct\n\n'
              'You retain ownership of any content you post on Peaka. By posting content, you grant Peaka a worldwide, non-exclusive, '
              'royalty-free license to use, copy, reproduce, process, adapt, modify, publish, transmit, display, and distribute such content.\n\n'
              'You agree not to post content that:\n'
              '• Is illegal, abusive, harassing, or threatening\n'
              '• Infringes on any third party\'s intellectual property rights\n'
              '• Contains viruses or malicious code\n'
              '• Promotes dangerous activities or extreme sports without proper safety warnings\n\n'
              '4. Safety and Risk Acknowledgment\n\n'
              'Peaka is a platform for extreme sports enthusiasts. You explicitly acknowledge that:\n'
              '• Extreme sports are inherently dangerous activities\n'
              '• You participate in any activities at your own risk\n'
              '• Peaka is not responsible for any injuries or damages resulting from activities coordinated through the App\n'
              '• You should always follow proper safety procedures and use appropriate safety equipment\n'
              '• You should verify the credentials and experience of any instructors or guides\n\n'
              '5. Account Security\n\n'
              'You are responsible for maintaining the security of your account and password. Peaka cannot and will not be liable for any loss or damage '
              'from your failure to comply with this security obligation. You should notify us immediately of any unauthorized use of your account.\n\n'
              '6. Intellectual Property\n\n'
              'The App and its original content, features, and functionality are owned by Peaka and are protected by international copyright, '
              'trademark, patent, trade secret, and other intellectual property laws.\n\n'
              '7. Termination\n\n'
              'We may terminate or suspend your account and access to the Service immediately, without prior notice or liability, '
              'under our sole discretion, for any reason whatsoever.\n\n'
              '8. Changes to Terms\n\n'
              'We reserve the right to modify or replace these Terms at any time. We will provide notice of any significant changes.\n\n'
              '9. Contact Information\n\n'
              'If you have any questions about these Terms, please contact us at:\n'
              'Email: support@peaka.com\n'
              '© 2025 Peaka. All rights reserved.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 