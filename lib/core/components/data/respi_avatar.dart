import 'package:flutter/material.dart';
import '../../theme/tokens/respi_typography.dart';

/// Patient or nurse avatar with initials fallback.
enum RespiAvatarSize { xs, sm, md, lg, xl }

class RespiAvatar extends StatelessWidget {
  const RespiAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = RespiAvatarSize.md,
    this.isOnline = false,
  });

  final String? imageUrl;
  final String? name;
  final RespiAvatarSize size;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dim = size.dimension;

    Widget avatar = CircleAvatar(
      radius: dim / 2,
      backgroundColor: cs.primaryContainer,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(_initials, style: RespiTypography.labelLarge.copyWith(color: cs.onPrimaryContainer, fontSize: size.fontSize))
          : null,
    );

    if (isOnline) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              width: size.onlineIndicatorSize, height: size.onlineIndicatorSize,
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B57), shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }
    return Semantics(
      label: name != null && name!.isNotEmpty ? name! : 'Avatar',
      child: avatar,
    );
  }

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }
}

extension RespiAvatarSizeX on RespiAvatarSize {
  double get dimension => switch (this) { RespiAvatarSize.xs => 24, RespiAvatarSize.sm => 32, RespiAvatarSize.md => 48, RespiAvatarSize.lg => 64, RespiAvatarSize.xl => 96 };
  double get fontSize => switch (this) { RespiAvatarSize.xs => 10, RespiAvatarSize.sm => 12, RespiAvatarSize.md => 16, RespiAvatarSize.lg => 22, RespiAvatarSize.xl => 32 };
  double get onlineIndicatorSize => switch (this) { RespiAvatarSize.xs => 8, RespiAvatarSize.sm => 10, RespiAvatarSize.md => 14, RespiAvatarSize.lg => 18, RespiAvatarSize.xl => 24 };
}
