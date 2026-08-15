import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/components/buttons/respi_button.dart';
import '../../../core/components/inputs/respi_text_field.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../providers/supabase_auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.resetPassword(email: _emailController.text.trim());
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RespiSpacing.screenPadding),
          child: _emailSent ? _buildSuccessState(cs) : _buildFormState(cs),
        ),
      ),
    );
  }

  Widget _buildFormState(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: RespiSpacing.xl),
        Icon(
          Icons.lock_reset_outlined,
          size: 64,
          color: cs.primary,
        ),
        const SizedBox(height: RespiSpacing.lg),
        const Text(
          'Forgot your password?',
          style: RespiTypography.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RespiSpacing.sm),
        Text(
          'Enter your email and we will send you a link to reset your password.',
          style: RespiTypography.bodyLarge.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RespiSpacing.xl),
        Form(
          key: _formKey,
          child: RespiTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'your@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: RespiSpacing.md),
          Text(
            _error!,
            style: RespiTypography.bodyMedium.copyWith(color: cs.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: RespiSpacing.xl),
        RespiButton(
          label: 'Send Reset Link',
          onPressed: _isLoading ? null : _submit,
          isLoading: _isLoading,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSuccessState(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: RespiSpacing.xxl),
        Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: cs.primary,
        ),
        const SizedBox(height: RespiSpacing.lg),
        const Text(
          'Check your email',
          style: RespiTypography.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RespiSpacing.sm),
        Text(
          'We have sent a password reset link to:\n${_emailController.text}',
          style: RespiTypography.bodyLarge.copyWith(
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RespiSpacing.xl),
        RespiButton(
          label: 'Back to Sign In',
          variant: RespiButtonVariant.outlined,
          onPressed: () => context.pop(),
          fullWidth: true,
        ),
      ],
    );
  }
}
