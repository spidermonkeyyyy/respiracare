import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/accessibility/focus_manager.dart';
import '../../../core/components/buttons/respi_button.dart';
import '../../../core/components/cards/respi_card.dart';
import '../../../core/components/inputs/respi_text_field.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  UserRole _selectedRole = UserRole.patient;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms to continue')),
      );
      return;
    }
    RespiFocusManager.unfocus(context);

    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (success && mounted) {
      if (_selectedRole == UserRole.nurse) {
        context.go(RouteNames.nurseDashboard);
      } else {
        context.go(RouteNames.patientHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;
    final errorMessage = authState.errorMessage;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RespiSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Join RespiraCare',
                  style: RespiTypography.headlineLarge,
                ),
                const SizedBox(height: RespiSpacing.sm),
                Text(
                  'Create your account to start monitoring your health.',
                  style: RespiTypography.bodyLarge.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RespiSpacing.xl),
                // Role selection
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Patient')),
                        selected: _selectedRole == UserRole.patient,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = UserRole.patient);
                          }
                        },
                        selectedColor: cs.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: RespiSpacing.sm),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Nurse')),
                        selected: _selectedRole == UserRole.nurse,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = UserRole.nurse);
                          }
                        },
                        selectedColor: cs.secondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RespiSpacing.xl),
                // Form card
                RespiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RespiTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Jane Doe',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            RespiFocusManager.request(_emailFocus),
                        focusNode: _nameFocus,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: RespiSpacing.lg),
                      RespiTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'your@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            RespiFocusManager.request(_passwordFocus),
                        focusNode: _emailFocus,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: RespiSpacing.lg),
                      RespiTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        isPassword: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            RespiFocusManager.request(_confirmFocus),
                        focusNode: _passwordFocus,
                        helper:
                            'At least 8 characters with letters and numbers',
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!value.contains(RegExp(r'[A-Za-z]')) ||
                              !value.contains(RegExp(r'[0-9]'))) {
                            return 'Include both letters and numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: RespiSpacing.lg),
                      RespiTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        isPassword: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        focusNode: _confirmFocus,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RespiSpacing.md),
                // Terms checkbox
                InkWell(
                  onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(RespiSpacing.sm),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) =>
                              setState(() => _agreedToTerms = v ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: RespiTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: RespiSpacing.md),
                // Error
                if (errorMessage != null)
                  RespiCard(
                    backgroundColor: cs.errorContainer,
                    borderColor: cs.error,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: cs.error),
                        const SizedBox(width: RespiSpacing.md),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: RespiTypography.bodyMedium.copyWith(
                              color: cs.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: RespiSpacing.lg),
                // Sign up button
                RespiButton(
                  label: 'Create Account',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                  variant: RespiButtonVariant.primary,
                  fullWidth: true,
                ),
                const SizedBox(height: RespiSpacing.xl),
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: RespiTypography.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.signIn),
                      child: Text(
                        'Sign In',
                        style: RespiTypography.labelLarge.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
