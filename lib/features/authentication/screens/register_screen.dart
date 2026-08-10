import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/inputs/app_input.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 1;
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  UserRole _selectedRole = UserRole.patient;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _proceedToStep2() {
    if (_formKeyStep1.currentState!.validate()) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKeyStep2.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          dateOfBirth: _dobController.text.trim().isEmpty
              ? null
              : _dobController.text.trim(),
        );

    if (success && mounted) {
      if (_selectedRole == UserRole.nurse) {
        context.go('/nurse/home');
      } else {
        context.go('/patient/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;
    final errorMessage = authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() {
                _currentStep = 1;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'Créer votre compte',
                subtitle: _currentStep == 1
                    ? 'Étape 1 sur 2 : Identifiants de connexion'
                    : 'Étape 2 sur 2 : Informations de profil',
              ),
              const SizedBox(height: AppSpacing.lg),

              // Step Indicator Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Container(
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: _currentStep == 2
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    errorMessage,
                    style: AppTypography.secondaryText.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              if (_currentStep == 1)
                _buildStep1Form()
              else
                _buildStep2Form(isLoading),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Form() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role Selection Selector
          Text(
            'Type de compte',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Patient')),
                  selected: _selectedRole == UserRole.patient,
                  onSelected: (selected) {
                    if (selected)
                      setState(() => _selectedRole = UserRole.patient);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: _selectedRole == UserRole.patient
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Infirmier(e)')),
                  selected: _selectedRole == UserRole.nurse,
                  onSelected: (selected) {
                    if (selected)
                      setState(() => _selectedRole = UserRole.nurse);
                  },
                  selectedColor: AppColors.secondary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: _selectedRole == UserRole.nurse
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          AppInput(
            label: 'Nom complet',
            hint: 'e.g. Ahmed Mansour',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez saisir votre nom complet';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

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
                return 'Veuillez saisir un mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          AppInput(
            label: 'Confirmer le mot de passe',
            hint: '••••••••',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          AppButton(
            text: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            onPressed: _proceedToStep2,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Form(bool isLoading) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: 'Numéro de téléphone',
            hint: '+212 6 XX XX XX XX',
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: 'Date de naissance',
            hint: 'AAAA-MM-JJ (e.g. 1965-04-12)',
            controller: _dobController,
            prefixIcon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Finaliser l\'inscription',
            icon: Icons.check_circle_outline_rounded,
            loading: isLoading,
            onPressed: isLoading ? null : _handleRegister,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
