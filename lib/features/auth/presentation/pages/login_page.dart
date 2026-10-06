import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/phone_otp_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthMode _mode = AuthMode.email;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(SignInWithEmailRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthStateData>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage && c.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to HireSignal',
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
                if (_mode == AuthMode.email)
                  _EmailForm(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    onSubmit: _submitEmail,
                    primaryLabel: 'Sign in',
                  )
                else
                  const PhoneOtpForm(),
                const SizedBox(height: 16),
                const _OrDivider(),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthStateData>(
                  buildWhen: (p, c) => p.submitting != c.submitting,
                  builder: (ctx, state) => GoogleSignInButton(
                    loading: state.submitting,
                    onPressed: () => ctx
                        .read<AuthBloc>()
                        .add(const SignInWithGoogleRequested()),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.signup),
                      child: const Text('Sign up'),
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
}

class _EmailForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onSubmit;
  final String primaryLabel;

  const _EmailForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.onSubmit,
    required this.primaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailCtrl,
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
            controller: passwordCtrl,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthBloc, AuthStateData>(
            buildWhen: (p, c) => p.submitting != c.submitting,
            builder: (ctx, state) => FilledButton(
              onPressed: state.submitting ? null : onSubmit,
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
                  : Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
