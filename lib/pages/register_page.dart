import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/base_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../widgets/user_type_selector.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../services/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  bool _acceptTerms = false;
  String? _selectedUserType;
  File? _idCard;
  final ImagePicker _picker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickIdImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => _idCard = File(file.path));
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accept terms')));
      return;
    }
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Driver or Client')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = FirebaseServiceLocator.instance.auth;
      final databaseService = FirebaseServiceLocator.instance.database;
      
      final userCredential = await authService.createUserWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      final uid = userCredential.user.uid;
      final userRef = databaseService.ref('users/$uid');

      await userRef.set({
        'uid': uid,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'userType': _selectedUserType,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registration Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your account has been created successfully.'),
              const SizedBox(height: 16),
              Text('Account Type: ${_selectedUserType == 'driver' ? 'Driver' : 'Client'}'),
              const SizedBox(height: 8),
              Text('Email: ${_emailCtrl.text}'),
              const SizedBox(height: 16),
              const Text('Please login with your new credentials.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('GO TO LOGIN'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildUserTypeButtons(),
                      const SizedBox(height: 24),
                      InputField(label: 'Full Name', hint: '', controller: _nameCtrl, validator: Validators.validateName),
                      const SizedBox(height: 16),
                      InputField(label: 'Email', hint: '', controller: _emailCtrl, validator: Validators.validateEmail),
                      const SizedBox(height: 16),
                      InputField(label: 'Phone', hint: '', controller: _phoneCtrl, validator: Validators.validatePhone),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Password',
                        hint: '',
                        controller: _passCtrl,
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        label: 'Confirm Password',
                        hint: '',
                        controller: _confirmCtrl,
                        obscureText: !_confirmVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_confirmVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
                        ),
                        validator: (v) => v == _passCtrl.text ? null : 'Password does not match',
                      ),
                      if (_selectedUserType == 'driver') ...[
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _pickIdImage,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppConstants.lightGrey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _idCard != null
                                ? Image.file(_idCard!, fit: BoxFit.cover)
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.add_a_photo),
                                        Text('Upload ID (Optional)'),
                                        SizedBox(height: 4),
                                        Text('You can upload later', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Checkbox(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v!)),
                          const Expanded(child: Text('I agree to Terms & Privacy')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomButton(text: 'Register', isLoading: _isLoading, onPressed: _onRegister),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top + 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF181D48), Color(0xFF3C348B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Positioned(
        top: MediaQuery.of(context).padding.top + 40,
        left: 0,
        right: 0,
        child: Center(
          child: Image.asset('assets/bypass_logo.png', width: 140, height: 140),
        ),
      ),
    );
  }

  Widget _buildUserTypeButtons() {
    return UserTypeSelector(
      selectedUserType: _selectedUserType ?? '',
      onUserTypeChanged: (t) => setState(() => _selectedUserType = t),
    );
  }
}