import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'user_dashboard_page.dart';
import 'Services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final Color primaryOrange = const Color(0xFFCC6B2C);
  final Color darkBrown     = const Color(0xFF2A1506);

  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  bool _obscurePass      = true;
  bool _isLoading        = false;

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
    _emailController.dispose();
    _passController.dispose(); // ✅ Fix 1: typo fix
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().signIn(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );
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
            // ── Dark gradient overlay ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),

            // ── Content ──
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ── Logo ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checkroom_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 6),
                          RichText(
                            text: TextSpan(children: [
                              const TextSpan(text: 'Shop',
                                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                              TextSpan(text: 'syra',
                                  style: TextStyle(color: primaryOrange, fontSize: 26, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Heading ──
                      const Text('Welcome Back!',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Login to continue finding nearby fashion.',
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14)),
                      const SizedBox(height: 32),

                      // ── White Card ──
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 12)),
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
                                child: Text('Login',
                                    style: TextStyle(color: darkBrown, fontSize: 22, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(height: 24),

                              // ── Email field ──
                              _buildField(
                                controller: _emailController,
                                hint: 'Enter your email',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) return 'Invalid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // ── Forgot password row ──
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Password',
                                      style: TextStyle(color: darkBrown.withOpacity(0.6),
                                          fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text('Forgot password?',
                                        style: TextStyle(color: primaryOrange,
                                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // ── Password field ──
                              _buildField(
                                controller: _passController,
                                hint: 'Enter your password',
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
                                  if (v == null || v.isEmpty) return 'Please enter your password';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // ── Login button ──
                              GestureDetector(
                                onTap: _isLoading ? null : _handleLogin,
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
                                      BoxShadow(color: primaryOrange.withOpacity(0.4),
                                          blurRadius: 16, offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(width: 22, height: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('Login',
                                                  style: TextStyle(color: Colors.white, fontSize: 16,
                                                      fontWeight: FontWeight.w800)),
                                              const SizedBox(width: 10),
                                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // ── Divider ──
                              Row(children: [
                                Expanded(child: Divider(color: darkBrown.withOpacity(0.15), thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or', style: TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 12)),
                                ),
                                Expanded(child: Divider(color: darkBrown.withOpacity(0.15), thickness: 1)),
                              ]),
                              const SizedBox(height: 16),

                              // ── Facebook button ──
                              _socialBtn(
                                color: const Color(0xFF1877F2),
                                icon: Icons.facebook_rounded,
                                label: 'Continue with Facebook',
                              ),
                              const SizedBox(height: 10),

                              // ── Google button ──
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
                                    Icon(Icons.g_mobiledata_rounded, color: const Color(0xFFDB4437), size: 26),
                                    const SizedBox(width: 8),
                                    Text('Continue with Google',
                                        style: TextStyle(color: darkBrown, fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Sign up link ──
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: darkBrown.withOpacity(0.55), fontSize: 13),
                                    children: [
                                      const TextSpan(text: 'New to Shopsyra? '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(context,
                                              MaterialPageRoute(builder: (_) => const SignupPage())),
                                          child: Text('Create an account',
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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