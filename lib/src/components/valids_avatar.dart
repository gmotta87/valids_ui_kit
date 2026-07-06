import 'package:flutter/material.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Size of a [ValidsAvatar]. `sm` and `md` match the ValiDS design system
/// (`size-lg` = 24 and `size-2xl` = 40); `lg` and `xl` are convenience
/// extensions beyond it, mapped to the nearest spacing tokens.
enum ValidsAvatarSize { sm, md, lg, xl }

/// Shape of a [ValidsAvatar]. The design system defaults to `square`
/// (`rounded-sm`).
enum ValidsAvatarShape { square, circle }

/// Color treatment of a [ValidsAvatar]: `brand`
/// (`bg-brand-secondary-default` + `text-invert`) or `neutral`
/// (`bg-default` + `text-default`).
enum ValidsAvatarKind { neutral, brand }

/// Avatar that displays an image, an icon or the initial extracted from a name.
///
/// Mirrors the design system's Avatar (`kind`, `shape`, `size`); as in the DS
/// `AvatarInitial`, only the first character of [name] is shown, uppercased.
/// The optional [backgroundColor] is a convenience extension that overrides
/// the [kind] colors when provided.
class ValidsAvatar extends StatelessWidget {
  final String? name;
  final IconData? icon;
  final ImageProvider? image;
  final ValidsAvatarSize size;
  final ValidsAvatarShape shape;
  final ValidsAvatarKind kind;
  final String? title;
  final Color? backgroundColor;

  const ValidsAvatar({
    super.key,
    this.name,
    this.icon,
    this.image,
    this.size = ValidsAvatarSize.md,
    this.shape = ValidsAvatarShape.square,
    this.kind = ValidsAvatarKind.brand,
    this.title,
    this.backgroundColor,
  });

  double get _dimension {
    switch (size) {
      case ValidsAvatarSize.sm:
        return ValidsSpacing.lg; // DS: size-lg (24)
      case ValidsAvatarSize.md:
        return ValidsSpacing.xl2; // DS: size-2xl (40)
      case ValidsAvatarSize.lg:
        return ValidsSpacing.xl4; // extension (56)
      case ValidsAvatarSize.xl:
        return ValidsSpacing.xl6; // extension (80)
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case ValidsAvatarSize.sm:
        return ValidsTypography.bodyHighlightSm; // DS: ts-body-highlight-sm
      case ValidsAvatarSize.md:
        return ValidsTypography.bodyHighlightMd; // DS: ts-body-highlight-md
      case ValidsAvatarSize.lg:
        return ValidsTypography.bodyHighlightLg; // extension
      case ValidsAvatarSize.xl:
        return ValidsTypography.headingLg; // extension
    }
  }

  /// DS `AvatarInitial`: first character of the label, uppercased.
  String get _initial {
    final String trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double dimension = _dimension;
    final bool hasImage = image != null;
    final bool isBrand = kind == ValidsAvatarKind.brand;

    final Color background = backgroundColor ??
        (isBrand ? ValidsColors.primary : ValidsColors.backgroundDefault);
    final Color foreground = backgroundColor != null
        ? ValidsColors.textInvert
        : (isBrand ? ValidsColors.textInvert : ValidsColors.textDefault);

    final Widget avatar = Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      // DS: p-2xs (images stay full-bleed, clipped by the shape).
      padding: hasImage ? null : const EdgeInsets.all(ValidsSpacing.xs2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: shape == ValidsAvatarShape.circle
            ? ValidsRadius.fullRadius
            : ValidsRadius.smRadius, // DS: rounded-sm
        image:
            hasImage ? DecorationImage(image: image!, fit: BoxFit.cover) : null,
      ),
      child: hasImage
          ? null
          : icon != null
              ? Icon(icon, size: dimension / 2, color: foreground)
              : Text(
                  _initial,
                  style: _textStyle.copyWith(color: foreground),
                ),
    );

    if (title != null) {
      return Tooltip(message: title!, child: avatar);
    }
    return avatar;
  }
}
