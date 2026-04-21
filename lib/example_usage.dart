import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

// ─────────────────────────────────────────────────────────────
// HOW TO USE AuthService & FirestoreService
// ─────────────────────────────────────────────────────────────

class ExampleUsagePage extends StatefulWidget {
  const ExampleUsagePage({super.key});

  @override
  State<ExampleUsagePage> createState() => _ExampleUsagePageState();
}

class _ExampleUsagePageState extends State<ExampleUsagePage> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _message = '';

  // ── 1. SIGN UP ───────────────────────────────────────────
  Future<void> _signUp() async {
    try {
      final credential = await _auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (credential != null) {
        // Save user profile to Firestore after sign up
        await _firestore.createUserProfile(
          name: _nameController.text,
          email: _emailController.text,
        );
        setState(() => _message = 'Sign up successful! UID: ${credential.user?.uid}');
      }
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  // ── 2. SIGN IN ───────────────────────────────────────────
  Future<void> _signIn() async {
    try {
      final credential = await _auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() => _message = 'Signed in as: ${credential?.user?.email}');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  // ── 3. SIGN OUT ──────────────────────────────────────────
  Future<void> _signOut() async {
    await _auth.signOut();
    setState(() => _message = 'Signed out.');
  }

  // ── 4. RESET PASSWORD ────────────────────────────────────
  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(_emailController.text);
      setState(() => _message = 'Password reset email sent!');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  // ── 5. GET USER PROFILE FROM FIRESTORE ───────────────────
  Future<void> _getProfile() async {
    try {
      final profile = await _firestore.getUserProfile();
      setState(() => _message = 'Profile: $profile');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  // ── 6. ADD A DOCUMENT TO FIRESTORE ───────────────────────
  Future<void> _addDocument() async {
    try {
      final ref = await _firestore.addDocument(
        collection: 'orders',
        data: {
          'item': 'Sample Product',
          'price': 299.99,
          'status': 'pending',
        },
      );
      setState(() => _message = 'Document added with ID: ${ref.id}');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  // ── 7. LISTEN TO AUTH STATE CHANGES ──────────────────────
  // Use this in your main app to redirect based on login state:
  //
  // StreamBuilder<User?>(
  //   stream: AuthService().authStateChanges,
  //   builder: (context, snapshot) {
  //     if (snapshot.hasData) return HomePage();
  //     return LoginPage();
  //   },
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController,     decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _emailController,    decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: _signUp,         child: const Text('Sign Up')),
                ElevatedButton(onPressed: _signIn,         child: const Text('Sign In')),
                ElevatedButton(onPressed: _signOut,        child: const Text('Sign Out')),
                ElevatedButton(onPressed: _resetPassword,  child: const Text('Reset Password')),
                ElevatedButton(onPressed: _getProfile,     child: const Text('Get Profile')),
                ElevatedButton(onPressed: _addDocument,    child: const Text('Add Document')),
              ],
            ),
            const SizedBox(height: 20),
            Text(_message, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}