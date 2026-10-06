import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

/// Two-step phone + OTP flow using Supabase.
///
/// Step 1 — user enters a phone number (E.164: `+91XXXXXXXXXX`) and taps
/// "Send OTP". The AuthBloc flips `otpSent` → true.
///
/// Step 2 — user enters the 6-digit code and taps "Verify". On success, the
/// AuthBloc authenticates and the surrounding page listens for the status
/// change to redirect.
class PhoneOtpForm extends StatefulWidget {
  const PhoneOtpForm({super.key});

  @override
  State<PhoneOtpForm> createState() => _PhoneOtpFormState();
}

class _PhoneOtpFormState extends State<PhoneOtpForm> {
  final _phoneCtrl = TextEditingController(text: '+91');
  final _otpCtrl = TextEditingController();
  final _phoneKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!(_phoneKey.currentState?.validate() ?? false)) return;
    context
        .read<AuthBloc>()
        .add(SendPhoneOtpRequested(phone: _phoneCtrl.text.trim()));
  }

  void _verify(String phone) {
    if (!(_otpKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(VerifyPhoneOtpRequested(
          phone: phone,
          token: _otpCtrl.text.trim(),
        ));
  }

  String? _validatePhone(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Enter your phone number';
    if (!value.startsWith('+')) return 'Include country code (e.g. +91…)';
    if (value.length < 10) return 'Too short';
    return null;
  }

  String? _validateOtp(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Enter the OTP';
    if (value.length < 4) return 'Invalid code';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthStateData>(
      builder: (context, state) {
        if (!state.otpSent) {
          return Form(
            key: _phoneKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+91XXXXXXXXXX',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  validator: _validatePhone,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.submitting ? null : _sendOtp,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: state.submitting
                      ? const _ButtonSpinner()
                      : const Text('Send OTP'),
                ),
              ],
            ),
          );
        }

        final phone = state.otpPhone ?? _phoneCtrl.text.trim();
        return Form(
          key: _otpKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We sent a code to $phone',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'One-time code',
                  counterText: '',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateOtp,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.submitting ? null : () => _verify(phone),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: state.submitting
                    ? const _ButtonSpinner()
                    : const Text('Verify'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.submitting
                    ? null
                    : () {
                        _otpCtrl.clear();
                        context.read<AuthBloc>().add(const PhoneOtpReset());
                      },
                child: const Text('Use a different number'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
}
