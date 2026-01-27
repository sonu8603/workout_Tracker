import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';
import '../Providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isLoading = false;


  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  //  Backend Update Username
  Future<void> _updateUsername(String newUsername) async {
    if (newUsername.isEmpty) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await ApiService.updateProfile(
      username: newUsername,
      email: authProvider.email ?? '',
      phone: authProvider.userData?['phone'] ?? '',
    );

    if (result['success']) {
      await authProvider.refreshProfile();
      _showMessage('Username updated successfully', isError: false);
    } else {
      _showMessage(result['message'] ?? 'Failed to update', isError: true);
    }
    setState(() => _isLoading = false);
  }

  //  Image Management
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, maxWidth: 512, imageQuality: 85);
    if (image != null) {
      setState(() => _isUploadingImage = true);
      try {
        final bytes = await File(image.path).readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        final result = await ApiService.updateProfileImage(base64Image);

        if (result['success']) {
          await Provider.of<AuthProvider>(context, listen: false).refreshProfile();
          _showMessage('Photo updated!', isError: false);
        }
      } catch (e) {
        _showMessage('Error uploading: $e', isError: true);
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String? photoUrl = authProvider.userData?['profileImage'];
    final String currentUsername = authProvider.username ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile Settings', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Section
            _buildProfileHeader(currentUsername, authProvider.email ?? '', photoUrl),

            const SizedBox(height: 30),

             Divider(height: 5,thickness: 3,),
            const SizedBox(height: 10),

            ListTile(
              onTap:  () => _showEditUsernameDialog(currentUsername),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 35),
              ),
              title: const Text(
                "edit username",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
            ),


                //  -->password change section

            const SizedBox(height:25),

            ListTile(
              onTap: () => Navigator.push(
                          context,
                           MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                        ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, size: 35),
              ),
              title: const Text(
                "change password",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String? url) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade50,
              backgroundImage: url != null && url.isNotEmpty
                  ? (url.startsWith('data:image')
                  ? MemoryImage(base64Decode(url.split(',')[1]))
                  : NetworkImage(url)) as ImageProvider
                  : null,
              child: (url == null || url.isEmpty)
                  ? Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                  : null,
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: _showPicker,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                  child: _isUploadingImage
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void _showPicker() {
    showModalBottomSheet(context: context, builder: (context) => SafeArea(
      child: Wrap(children: [
        ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
        ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Camera'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
      ]),
    ));
  }

  void _showEditUsernameDialog(String current) {
    final controller = TextEditingController(text: current);
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('New Username'),
      content: TextField(controller: controller),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); _updateUsername(controller.text.trim()); }, child: const Text('Save')),
      ],
    ));
  }

  Widget _buildSettingTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}


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
      appBar: AppBar(title: const Text('Change Password')),
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