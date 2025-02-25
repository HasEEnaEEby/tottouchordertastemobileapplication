import 'package:flutter/material.dart';

import 'support_card.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SupportCard(
              icon: Icons.chat,
              title: 'Chat with Us',
              subtitle: 'Get instant support from our team',
              onTap: () {
                // Stub: implement chat support
                print('Chat support tapped');
              },
            ),
            SupportCard(
              icon: Icons.call,
              title: 'Call Support',
              subtitle: 'Speak with our customer service',
              onTap: () {
                // Stub: implement call support
                print('Call support tapped');
              },
            ),
            SupportCard(
              icon: Icons.mail,
              title: 'Email Support',
              subtitle: 'Send us your queries',
              onTap: () {
                // Stub: implement email support
                print('Email support tapped');
              },
            ),
            SupportCard(
              icon: Icons.help,
              title: 'FAQs',
              subtitle: 'Find answers to common questions',
              onTap: () {
                // Stub: implement FAQs
                print('FAQs tapped');
              },
            ),
          ],
        ),
      ),
    );
  }
}
