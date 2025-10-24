import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_client.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // New UI state for Account selection
  // If a subdomain is already configured on this device, we won't ask for it again
  bool _isSubdomainConfigured = false;
  String? _configuredSubdomain;
  final _accountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfiguredSubdomain();
  }

  Future<void> _loadConfiguredSubdomain() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(StorageKeys.apiSubdomain);
    if (saved != null && saved.isNotEmpty) {
      _isSubdomainConfigured = true;
      _configuredSubdomain = saved;
      // Apply to ApiClient immediately so any subsequent requests use it
      ApiClient().setApiSubdomain(saved);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // If subdomain not configured yet (first launch), require and persist it
    if (!_isSubdomainConfigured) {
      final account = _accountController.text.trim().toLowerCase();
      if (account.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account/subdomain is required for first-time login.')),
        );
        return;
      }

      // Persist and apply
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.apiSubdomain, account);
      ApiClient().setApiSubdomain(account);
      _isSubdomainConfigured = true;
      _configuredSubdomain = account;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // If successful, GoRouter will automatically redirect based on user role
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dim overlay for readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15), // subtle frosted glass
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // App logo (matches the requested layout)
                            Center(
                              child: Image.asset(
                                'assets/images/logo transparent.png',
                                height: 96,
                                width: 96,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In title
                            Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Account (only required on first launch)
                            if (!_isSubdomainConfigured) ...[
                              Text(
                                'Account',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _accountController,
                                decoration: const InputDecoration(
                                  labelText: 'Account',
                                  hintText: 'e.g. john (this will be used as subdomain)',
                                  prefixIcon: Icon(Icons.domain),
                                ),
                                validator: (value) {
                                  if (!_isSubdomainConfigured) {
                                    if (value == null || value.trim().isEmpty) return 'Account is required';
                                    if (value.contains(' ')) return 'No spaces allowed';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                            ] else ...[
                              // Optionally show configured account
                              Text(
                                'Account: ${_configuredSubdomain ?? ''}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 8),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Forgot password feature coming soon'),
                                    ),
                                  );
                                },
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login button
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _login,
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Note: Register / Sign up logic intentionally omitted per request

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
