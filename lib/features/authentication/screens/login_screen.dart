import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import 'package:respiracare/core/widgets/buttons/app_button.dart';
import 'package:respiracare/core/widgets/cards/app_card.dart';
import 'package:respiracare/core/widgets/inputs/app_input.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _clientError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _clientError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );

    if (success && mounted) {
      final user = ref.read(authProvider).currentUser;
      if (user != null) {
        if (user.role == UserRole.nurse) {
          context.go('/nurse/home');
        } else {
          context.go('/patient/home');
        }
      }
    }
  }

  void _fillMockCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    ref.read(authProvider.notifier).clearError();
    setState(() {
      _clientError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;
    final errorMessage = authState.errorMessage ?? _clientError;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Bienvenue',
                  subtitle: 'Connectez-vous à votre espace Sanad',
                ),
                const SizedBox(height: AppSpacing.xl),

                // Error Notification Box
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.danger,
                          size: 20.0,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: AppTypography.secondaryText.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Input Fields
                AppInput(
                  label: 'Adresse e-mail',
                  hint: 'nom@exemple.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre adresse e-mail';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Veuillez saisir une adresse e-mail valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                AppInput(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xs),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Un lien de réinitialisation sera envoyé à votre adresse e-mail.',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTypography.secondaryText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Login Submit Button
                AppButton(
                  text: 'Se connecter',
                  icon: Icons.login_rounded,
                  loading: isLoading,
                  onPressed: isLoading ? null : _handleLogin,
                  fullWidth: true,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Registration Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte ? ',
                      style: AppTypography.secondaryText,
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(authProvider.notifier).clearError();
                        context.push('/register');
                      },
                      child: Text(
                        'Créer un compte',
                        style: AppTypography.secondaryText.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Quick Mock Accounts Bar for Developer Testing
                AppCard(
                  backgroundColor:
                      AppColors.surfaceVariant.withValues(alpha: 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.developer_mode_rounded,
                            size: 16.0,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Comptes de démonstration (Test rapide)',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _fillMockCredentials(
                                'patient@respiracare.org',
                                'password123',
                              ),
                              child: const Text('Compte Patient'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _fillMockCredentials(
                                'nurse@respiracare.org',
                                'password123',
                              ),
                              child: const Text('Compte Infirmier'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
