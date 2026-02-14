import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workout_tracker/setting_editing/password_change_screen.dart';
import 'dart:convert';
import 'dart:io';
import '../login_sign_up/logIn_screen.dart';
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

  // ================= HELPERS =================

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ================= CORE LOGIC =================

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

  // 🔥 NEW: Delete Account Logic
  Future<void> _handleDeleteAccount(String password) async {
    if (password.isEmpty) {
      _showMessage('Password required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.deleteAccount(password);

      if (!mounted) return;

      if (success) {
        // 1. Stop the loading spinner
        setState(() => _isLoading = false);

        if (mounted) {
          // 2. Direct Navigation: Type-safe and guaranteed to work
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LogInScreen(),
            ),
                (route) => false,
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showMessage(authProvider.error ?? 'Error deleting account', isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showMessage('Unexpected error: $e', isError: true);
      }
    }
  }


  // ================= DIALOGS =================

  void _showEditUsernameDialog(String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter username"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateUsername(controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDangerDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This is permanent. Your profile will be deactivated and workout data hidden.'),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Verify Password',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context);
                _handleDeleteAccount(passwordController.text.trim());
              } else {
                _showMessage('Password required to delete', isError: true);
              }
            },
            child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= UI BUILD =================

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
        title: const Text('Profile Settings',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(currentUsername, authProvider.email ?? '', photoUrl),
                const SizedBox(height: 30),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 10),

                // Edit Username
                _buildSettingTile(
                  title: "Edit Username",
                  icon: Icons.person,
                  iconColor: Colors.blue,
                  onTap: () => _showEditUsernameDialog(currentUsername),
                ),

                const SizedBox(height: 15),

                // Change Password
                _buildSettingTile(
                  title: "Change Password",
                  icon: Icons.lock,
                  iconColor: Colors.deepPurple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                  ),
                ),

                const SizedBox(height: 40),

                // Danger Zone Section
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("DANGER ZONE",
                          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 10),

                _buildSettingTile(
                  title: "Delete Account",
                  icon: Icons.delete_forever,
                  iconColor: Colors.red,
                  onTap: _showDeleteDangerDialog,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                  : null,
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: () => _showPicker(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                  child: _isUploadingImage
                      ? const SizedBox(width: 15, height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
        ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }
        ),
        ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }
        ),
      ]),
    ));
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.blue,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: textColor.withOpacity(0.5)),
    );
  }
}