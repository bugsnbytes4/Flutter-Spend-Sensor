// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
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
      appBar: AppBar(title: Text('SpendSense — Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  Text(_error!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                ],
                TextField(controller: _emailCtl, decoration: InputDecoration(labelText: 'Email')),
                SizedBox(height: 8),
                TextField(controller: _passCtl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : () async {
                          setState(() => _loading = true);
                          try {
                            await auth.signInWithEmail(_emailCtl.text.trim(), _passCtl.text.trim());
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally { setState(() => _loading = false); }
                        },
                        child: Text('Sign in'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : () async {
                          setState(() => _loading = true);
                          try {
                            await auth.registerWithEmail(_emailCtl.text.trim(), _passCtl.text.trim());
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally { setState(() => _loading = false); }
                        },
                        child: Text('Register'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: Text('Sign in with Google'),
                  onPressed: _loading ? null : () async {
                    setState(() => _loading = true);
                    try {
                      await auth.signInWithGoogle();
                    } catch (e) {
                      setState(() => _error = e.toString());
                    } finally { setState(() => _loading = false); }
                  },
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: _loading ? null : () async { setState(() => _loading = true); await auth.signInAnonymously(); setState(() => _loading = false); },
                  child: Text('Continue anonymously'),
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
