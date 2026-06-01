import 'package:flutter/material.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';
import 'package:archify_app/services/auth_service.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, AuthService? authService})
      : _authService = authService;

  final AuthService? _authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _auth = widget._authService ?? AuthService();

  bool _pending = false;
  String? _errorMessage;

  Future<void> _loginWithMicrosoft() async {
    setState(() {
      _pending = true;
      _errorMessage = null;
    });

    try {
      final token = await _auth.loginWithMicrosoft();

      if (!mounted) return;

      if (token != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CameraPermissionScreen()),
        );
        return;
      }

      // Gebruiker heeft geannuleerd
      setState(() => _pending = false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _pending = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pending = false;
        _errorMessage = 'Er is een onbekende fout opgetreden.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: ArchifyLogo(fontSize: 40)),
                  const SizedBox(height: 40),
                  const Text(
                    'Login op Archify',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading,
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: const Color(0xFFFFEAEC),
                      child: Text(
                        _errorMessage!,
                        key: const Key('login-error'),
                        style: const TextStyle(
                          color: Color(0xFFE50910),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('login-microsoft'),
                      onPressed: _pending ? null : _loginWithMicrosoft,
                      icon: _pending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(LucideIcons.logIn, size: 18),
                      label: const Text('Inloggen met Microsoft'),
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
