import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7165D6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 23),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privacy & Security'),
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy & Data Protection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  'Your privacy is important to us. This app does not collect, store, '
                      'or share any personal information. All workout data is securely '
                      'stored locally on your device.',
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 12),
                Text(
                  'Security Practices',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text('• All data remains on your device and is never uploaded'),
                SizedBox(height: 6),
                Text('• No third-party services or trackers are used'),
                SizedBox(height: 6),
                Text('• You can delete or reset your data anytime'),
                SizedBox(height: 6),
                Text('• Device-level security protects your information'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
