// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('SpendSense — Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(
                  controller: _passCtl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                setState(() => _loading = true);
                                try {
                                  await auth.signInWithEmail(
                                    _emailCtl.text.trim(),
                                    _passCtl.text.trim(),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  setState(() => _loading = false);
                                }
                              },
                        child: const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                setState(() => _loading = true);
                                try {
                                  await auth.registerWithEmail(
                                    _emailCtl.text.trim(),
                                    _passCtl.text.trim(),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  setState(() => _loading = false);
                                }
                              },
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            await auth.signInWithGoogle();
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally {
                            setState(() => _loading = false);
                          }
                        },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          try {
                            await auth.signInAnonymously();
                            if (!mounted) return;
                            // Ensure navigation proceeds even if auth stream is delayed
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  child: const Text('Continue anonymously'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }
}

