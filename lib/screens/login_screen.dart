import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:archify_app/screens/camera_permission_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:archify_app/services/api_service.dart';
import 'package:archify_app/services/auth_service.dart';
import 'package:archify_app/theme/app_theme.dart';
import 'package:archify_app/widgets/archify_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    ApiService? apiService,
    AuthService? authService,
  }) : _apiService = apiService,
       _authService = authService;

  final ApiService? _apiService;
  final AuthService? _authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final ApiService _api = widget._apiService ?? ApiService();
  late final AuthService _auth = widget._authService ?? AuthService();

  bool _pending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'E-mailadres is verplicht.';
    if (!_emailRegex.hasMatch(v)) {
      return 'Vul een geldig e-mailadres in.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wachtwoord is verplicht.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _pending = true);

    final result = await _api.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.success && result.token != null) {
      await _auth.saveToken(result.token!);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CameraPermissionScreen()),
      );
      return;
    }

    setState(() {
      _pending = false;
      _errorMessage = result.message ?? 'Inloggen mislukt.';
    });
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
                  const SizedBox(height: 24),
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
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AuthField(
                          label: 'E-mailadres',
                          required: true,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                          fieldKey: const Key('login-email'),
                        ),
                        const SizedBox(height: 16),
                        _AuthField(
                          label: 'Wachtwoord',
                          required: true,
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          validator: _validatePassword,
                          onSubmitted: (_) => _submit(),
                          fieldKey: const Key('login-password'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            key: const Key('login-submit'),
                            onPressed: _pending ? null : _submit,
                            child: _pending
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('Inloggen'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                      children: [
                        const TextSpan(text: 'Nog geen account? '),
                        TextSpan(
                          text: 'Neem contact op',
                          style: const TextStyle(
                            color: AppColors.magenta,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                launchUrl(Uri.parse('mailto:team@cbyte.nl')),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    this.fieldKey,
  });

  final String label;
  final bool required;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: AppColors.magenta),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(color: AppColors.darkNavy, fontSize: 15),
          cursorColor: AppColors.magenta,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: AppColors.white,
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.magenta, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.magenta),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.magenta, width: 1.5),
            ),
            errorStyle: TextStyle(color: AppColors.magenta, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
