// lib/pages/profile/edit_profile_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../managers/profile_manager.dart';

/// Data returned after editing: name, phone, email, dob, and optional new avatar.
class ProfileUpdate {
  final String name;
  final String phone;
  final String email;
  final String dob;
  final File? avatarFile;

  ProfileUpdate({
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    this.avatarFile,
  });
}

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialEmail;
  final String initialDob;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.initialEmail,
    required this.initialDob,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _picker  = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;

  File? _pickedAvatar;

  @override
  void initState() {
    super.initState();
    _nameController  = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
    _dobController   = TextEditingController(text: widget.initialDob);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Let user pick a new avatar from camera or gallery.
  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    setState(() => _pickedAvatar = File(picked.path));

    // Optionally update the global avatar immediately:
    await ProfileManager().updateAvatar(_pickedAvatar!);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated')),
    );
  }

  /// Open date picker and update the DOB field.
  Future<void> _pickDob() async {
    final parsed = DateTime.tryParse(widget.initialDob) ?? DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2,'0')}/'
          '${picked.month.toString().padLeft(2,'0')}/'
          '${picked.year}';
      _dobController.text = formatted;
    }
  }

  /// Validate inputs and pop with the new ProfileUpdate.
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(ProfileUpdate(
      name:       _nameController.text.trim(),
      phone:      _phoneController.text.trim(),
      email:      _emailController.text.trim(),
      dob:        _dobController.text.trim(),
      avatarFile: _pickedAvatar,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final surface    = theme.colorScheme.surface;
    //final onSurface  = theme.colorScheme.onSurface;
    final accent     = theme.colorScheme.primary;
    final onAccent   = theme.colorScheme.onPrimary;
    final isDark     = theme.brightness == Brightness.dark;
    final borderColor= isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: accent,
        foregroundColor: onAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Top-centered avatar with blue check
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedAvatar != null
                              ? FileImage(_pickedAvatar!)
                              : ProfileManager().avatarImage,
                        ),
                      ),
                      const Positioned(
                        right: -4,
                        bottom: -4,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
                  ),

                  const SizedBox(height: 16),

                  // Phone (disabled for future enable)
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    enabled: false,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Enter phone number' : null,
                  ),

                  const SizedBox(height: 16),

                  // DOB picker
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _pickDob,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Select date of birth' : null,
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter valid email' : null,
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _save,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
