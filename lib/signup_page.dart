import 'package:flutter/material.dart';
import 'user_dashboard_page.dart';
import 'Services/auth_service.dart';
import 'Services/firestore_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);
  final Color heroBg        = const Color(0xFFEDE8E0);

  final _formKey            = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passController     = TextEditingController();
  final _phoneController    = TextEditingController();
  final _cityController     = TextEditingController();
  final _addressController  = TextEditingController(); // ✅ NAYA
  final _pincodeController  = TextEditingController(); // ✅ NAYA
  bool _obscurePass         = true;
  bool _agreeTerms          = false;
  bool _isLoading           = false;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose(); // ✅ NAYA
    _pincodeController.dispose(); // ✅ NAYA
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please agree to Terms & Conditions'), backgroundColor: primaryOrange),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final credential = await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
      if (credential?.user == null) throw 'Signup failed';
      
      await credential!.user!.updateDisplayName(_nameController.text.trim());
      
      final error = await UserFirestoreService().saveUserData(
        uid: credential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );
      
      if (error != null) throw error;
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserDashboardPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: primaryOrange),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ──
            Image.asset('assets/landingpage.jpg', fit: BoxFit.cover),
            // ── Dark overlay ──
            Container(color: Colors.black.withOpacity(0.35)),
            // ── Content ──
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // ── Logo ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.checkroom_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 6),
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(
                                text: 'Shop',
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              TextSpan(
                                text: 'syra',
                                style: TextStyle(color: primaryOrange, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Heading ──
                      const Text('Join Shopsyra!',
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Create an account to explore nearby fashion.',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.5)),
                      const SizedBox(height: 28),

                      // ── Card ──
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 10)),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card title
                              Center(
                                child: Text('Sign Up',
                                    style: TextStyle(color: darkBrown, fontSize: 20, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(height: 22),

                              // Name
                              _buildField(
                                controller: _nameController,
                                hint: 'Enter your name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                              ),
                              const SizedBox(height: 14),

                              // Email
                              _buildField(
                                controller: _emailController,
                                hint: 'Enter your email',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) return 'Invalid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Phone
                              _buildField(
                                controller: _phoneController,
                                hint: 'Enter your phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Enter your phone number';
                                  if (v.trim().length < 10) return 'Enter a valid phone number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Address ✅ NAYA
                              _buildField(
                                controller: _addressController,
                                hint: 'Enter your address',
                                icon: Icons.home_outlined,
                                maxLines: 2,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your address' : null,
                              ),
                              const SizedBox(height: 14),

                              // City + Pincode ✅ ROW MEIN
                              Row(children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildField(
                                    controller: _cityController,
                                    hint: 'City',
                                    icon: Icons.location_city_outlined,
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: _buildField(
                                    controller: _pincodeController,
                                    hint: 'Pincode',
                                    icon: Icons.pin_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Required';
                                      if (v.trim().length != 6) return '6 digits';
                                      return null;
                                    },
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 14),

                              // Password
                              _buildField(
                                controller: _passController,
                                hint: 'Create a password',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePass,
                                suffix: GestureDetector(
                                  onTap: () => setState(() => _obscurePass = !_obscurePass),
                                  child: Icon(
                                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: darkBrown.withOpacity(0.4), size: 19,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter a password';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Terms checkbox
                              GestureDetector(
                                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 20, height: 20,
                                      decoration: BoxDecoration(
                                        color: _agreeTerms ? primaryOrange : Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: _agreeTerms ? primaryOrange : darkBrown.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _agreeTerms
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: darkBrown.withOpacity(0.6), fontSize: 12.5),
                                        children: [
                                          const TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Sign Up button
                              GestureDetector(
                                onTap: _isLoading ? null : _handleSignup,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity, height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isLoading
                                          ? [Colors.grey.shade400, Colors.grey.shade500]
                                          : [primaryOrange, const Color(0xFFA8481A)],
                                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(color: primaryOrange.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(width: 22, height: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Sign Up',
                                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                              SizedBox(width: 10),
                                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Divider
                              Row(children: [
                                Expanded(child: Divider(color: darkBrown.withOpacity(0.15), thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or', style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 12)),
                                ),
                                Expanded(child: Divider(color: darkBrown.withOpacity(0.15), thickness: 1)),
                              ]),
                              const SizedBox(height: 16),

                              // Facebook button
                              _socialBtn(
                                color: const Color(0xFF1877F2),
                                icon: Icons.facebook_rounded,
                                label: 'Sign up with Facebook',
                              ),
                              const SizedBox(height: 10),

                              // Google button
                              Container(
                                width: double.infinity, height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: darkBrown.withOpacity(0.15), width: 1.2),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.g_mobiledata_rounded, color: Color(0xFFDB4437), size: 26),
                                    const SizedBox(width: 8),
                                    Text('Sign up with Google',
                                        style: TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: darkBrown.withOpacity(0.55), fontSize: 13),
                                    children: [
                                      const TextSpan(text: 'Already have an account? '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Text('Log in',
                                              style: TextStyle(
                                                  color: primaryOrange, fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: primaryOrange)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialBtn({required Color color, required IconData icon, required String label}) {
    return Container(
      width: double.infinity, height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: darkBrown, fontSize: 14.5, fontWeight: FontWeight.w500),
      cursorColor: primaryOrange,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: darkBrown.withOpacity(0.35), fontSize: 14),
        prefixIcon: Icon(icon, color: primaryOrange, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBrown.withOpacity(0.1), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}