import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../../core/components/buttons/respi_button.dart';

/// Prompts for biometric authentication when available.
class BiometricPrompt extends ConsumerStatefulWidget {
  const BiometricPrompt({super.key});

  @override
  ConsumerState<BiometricPrompt> createState() => _BiometricPromptState();
}

class _BiometricPromptState extends ConsumerState<BiometricPrompt> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final availableBiometrics = await _localAuth.getAvailableBiometrics();
    if (mounted) {
      setState(() {
        _isAvailable = isAvailable && availableBiometrics.isNotEmpty;
        _availableBiometrics = availableBiometrics;
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your health data',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'RespiraCare Authentication',
            cancelButton: 'Cancel',
            biometricHint: 'Verify your identity',
            biometricNotRecognized: 'Not recognized, try again',
            biometricRequiredTitle: 'Biometric authentication required',
            deviceCredentialsRequiredTitle: 'Device credentials required',
            deviceCredentialsSetupDescription:
                'Please set up device credentials',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in Settings',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription:
                'Please set up biometric authentication in Settings',
            lockOut: 'Please re-enable biometric authentication',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate && mounted) {
        // TODO: Retrieve stored credentials and sign in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication successful')),
        );
      }
    } catch (e) {
      // Biometric auth failed or was cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) return const SizedBox.shrink();

    final isFaceId = _availableBiometrics.contains(BiometricType.face);
    final isFingerprint =
        _availableBiometrics.contains(BiometricType.fingerprint);

    String label;
    IconData icon;

    if (isFaceId) {
      label = 'Sign in with Face ID';
      icon = Icons.face;
    } else if (isFingerprint) {
      label = 'Sign in with Fingerprint';
      icon = Icons.fingerprint;
    } else {
      label = 'Sign in with Biometrics';
      icon = Icons.security;
    }

    return RespiButton(
      label: label,
      icon: icon,
      variant: RespiButtonVariant.outlined,
      onPressed: _authenticate,
      fullWidth: true,
    );
  }
}
