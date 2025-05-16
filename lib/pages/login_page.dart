import 'package:flutter/material.dart';
import '../widgets/base_page.dart';
import 'customer_home_page.dart';
import 'driver_home_page.dart';
import '../utils/validators.dart'; //import the validators
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); 
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _selectedUserType;

  // hover flags:
  bool _isDriverHovered = false;
  bool _isClientHovered = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Driver or Client')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = FirebaseServiceLocator.instance.auth;
      final userCredential = await authService.signInWithEmailAndPassword(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final newUser = UserModel(
        id: userCredential.user.uid,
        name: userCredential.user.email ?? 'Unknown',
        email: userCredential.user.email ?? '',
        phone: userCredential.user.phoneNumber,
      );

      userProvider.setUser(newUser);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Successful'),
          content: const Text('Welcome back! You have successfully logged in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => _selectedUserType == 'driver'
                        ? const DriverHomePage()
                        : const CustomerHomePage(),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  height: MediaQuery.of(context).padding.top + 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF181D48), Color(0xFF3C348B)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 16,
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.language, color: Colors.white, size: 20),
                          label: const Text('EN', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset( 
                            
                            'assets/bypass_logo.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Form( 


                    key: _formKey,
                    


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [


                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: _buildUserTypeButtons(),
                        ),
                        const SizedBox(height: 24),
                        _buildLoginForm(), 
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //── Driver / Client Buttons ─────────────────────────────────────────────
  Widget _buildUserTypeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildUserTypeButton(
            title: 'DRIVER',
            icon: Icons.local_shipping,
            color: const Color(0xFFE3531C),
            bgColor: const Color(0x19E3531C),
            isSelected: _selectedUserType == 'driver',
            onTap: () => setState(() => _selectedUserType = 'driver'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUserTypeButton(
            title: 'CLIENT',
            icon: Icons.person,
            color: const Color(0xFFF3B334),
            bgColor: const Color(0x19F3B334),
            isSelected: _selectedUserType == 'client',
            onTap: () => setState(() => _selectedUserType = 'client'),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeButton({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool isHovered = (title == 'DRIVER') ? _isDriverHovered : _isClientHovered;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          if (title == 'DRIVER') _isDriverHovered = true;
          else _isClientHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          if (title == 'DRIVER') _isDriverHovered = false;
          else _isClientHovered = false;
        });
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected || isHovered ? color : const Color(0xFFE5E7EB),
              width: isSelected || isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected || isHovered)
                    ? color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHovered || isSelected ? 52 : 48,
                height: isHovered || isSelected ? 52 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected || isHovered ? color.withOpacity(0.2) : bgColor,
                ),
                child: Icon(icon, color: color, size: isHovered || isSelected ? 28 : 24),
              ),
              const SizedBox(height: 16),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isHovered || isSelected ? 17 : 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected || isHovered ? color : const Color(0xFF181D48),
                ),
                child: Text(title),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Rest of Form ─────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    // No need to wrap this part in Form again, it's already inside the Form in build method
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          label: 'Email', // Changed label to Email to match validator
          controller: _usernameController, // Assuming this controller is for email
          icon: Icons.email_outlined, // Changed icon to email
          // Use Validators.validateEmail for the email field
          validator: Validators.validateEmail,
          keyboardType: TextInputType.emailAddress, // Set keyboard type for email
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'Password',
          controller: _passwordController,
          icon: Icons.lock_outline,
          isPassword: true,
          
          
          validator: Validators.validatePassword,
        ),
        // Add test credentials hint
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Test Accounts:\nClient: user@example.com / password123\nDriver: test@test.com / test123',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        _buildLoginButton(),
        const SizedBox(height: 24),
        _buildDivider(),
        const SizedBox(height: 24),
        _buildSocialLogin(),
        const SizedBox(height: 24),
        _buildCreateAccount(),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    FormFieldValidator<String>? validator, 
    
    TextInputType? keyboardType, 
    
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        ),
        Container(
          
          

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            color: Colors.white,
          ),
          
          

          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            style: const TextStyle(fontSize: 16),
            validator: validator, 
            
            keyboardType: keyboardType, 
            

            autovalidateMode: AutovalidateMode.onUserInteraction, 
            

            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: const Color(0xFF181D48)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF181D48)),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              
              
          
              errorStyle: const TextStyle(fontSize: 12, height: 1.2), 
              
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _onLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE3531C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFE4E6EB), thickness: 1)),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF767676)))),
        Expanded(child: Divider(color: Color(0xFFE4E6EB), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.white),
            label: const Text('iCloud'),
            onPressed: () async {
              final email = 'user@icloud.com';
              
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting to iCloud...')));
              setState(() => _isLoading = true);
              
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) return;
              
              setState(() => _isLoading = false);
              
              // Create a user model for the social login
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final newUser = UserModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'iCloud User',
                email: email,
                phone: null,
              );
              
              // Set the current user in the provider
              userProvider.setUser(newUser);
              
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
                return _selectedUserType == 'driver' ? const DriverHomePage() : const CustomerHomePage();
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Colors.white),
            label: const Text('Google'),
            onPressed: () async {
              final email = 'user@gmail.com';
              
              
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting to Google...')));
              setState(() => _isLoading = true);
              
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) return;
              
              setState(() => _isLoading = false);
              
              // Create a user model for the social login
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final newUser = UserModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'Google User',
                email: email,
                phone: null,
              );
              
              // Set the current user in the provider
              userProvider.setUser(newUser);
              
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
                return _selectedUserType == 'driver' ? const DriverHomePage() : const CustomerHomePage();
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccount() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        child: const Text(
          'Create Account',
          style: TextStyle(color: Color(0xFF181D48), decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
