

 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/auth_provider.dart';
import '../services/api_service.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPass = TextEditingController();
  final _newPass = TextEditingController();
  bool _loading = false;

  Future<void> _updatePassword() async {
    if (_currentPass.text.isEmpty || _newPass.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Password (min 6 chars)')));
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final result = await ApiService.updateProfile(
      username: auth.username ?? '',
      email: auth.email ?? '',
      phone: auth.userData?['phone'] ?? '',
      currentPassword: _currentPass.text,
      newPassword: _newPass.text,
    );

    setState(() => _loading = false);
    if (result['success']) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Changed!'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),


      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _currentPass, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 15),
            TextField(controller: _newPass, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 30),
            _loading ? const CircularProgressIndicator() : ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}