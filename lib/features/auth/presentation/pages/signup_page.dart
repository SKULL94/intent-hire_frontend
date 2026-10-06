import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/phone_otp_form.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  AuthMode _mode = AuthMode.email;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(SignUpWithEmailRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthStateData>(
      listenWhen: (p, c) =>
          (p.errorMessage != c.errorMessage && c.errorMessage != null) ||
          (p.status != c.status && c.status == AuthStatus.authenticated),
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.status == AuthStatus.authenticated) {
          context.go(RoutePaths.skillSetup);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Takes about 60 seconds',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                AuthModeToggle(
                  mode: _mode,
                  onChanged: (m) {
                    setState(() => _mode = m);
                    context.read<AuthBloc>().add(const PhoneOtpReset());
                  },
                ),
                const SizedBox(height: 24),
                if (_mode == AuthMode.email) _buildEmailForm() else const PhoneOtpForm(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.login),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name (optional)'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Enter your email';
              if (!value.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter a password';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthBloc, AuthStateData>(
            buildWhen: (p, c) => p.submitting != c.submitting,
            builder: (ctx, state) => FilledButton(
              onPressed: state.submitting ? null : _submitEmail,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: state.submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}
