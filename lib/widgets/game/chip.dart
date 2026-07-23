import 'dart:ui' as ui;

import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/app_motion.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:flutter/material.dart' hide Chip;

class ChipWidget extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color overlayColor;
  final Color backgroundColor;
  final Color fontColor;
  final double fontSize;
  final double size;

  /// When both this and [photoSrcRect] are set (photo puzzle mode), the
  /// corresponding slice of [photoImage] is painted instead of [text].
  final ui.Image? photoImage;
  final Rect? photoSrcRect;

  const ChipWidget(
    this.text,
    this.overlayColor,
    this.backgroundColor,
    this.fontColor,
    this.fontSize, {
    super.key,
    this.onPressed,
    required this.size,
    this.photoImage,
    this.photoSrcRect,
  });

  @override
  State<ChipWidget> createState() => _ChipWidgetState();
}

class _ChipWidgetState extends State<ChipWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (!AppMotion.disableAnimations(context)) {
      _controller.forward();
    }
  }

  void _onTapEnd() {
    if (!AppMotion.disableAnimations(context)) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.size < 150;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final radius = isCompact ? AppRadii.xs : AppRadii.sm;
    final tilePadding = isCompact ? 3.0 : 6.0;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );

    var color = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (isIOS) {
      color = color.withValues(alpha: 0.7);
    }
    color = Color.alphaBlend(widget.backgroundColor, color);
    color = Color.alphaBlend(widget.overlayColor, color);

    final photoImage = widget.photoImage;
    final photoSrcRect = widget.photoSrcRect;
    final tileContent = photoImage != null && photoSrcRect != null
        ? SizedBox.expand(
            child: CustomPaint(
              painter: _PhotoTilePainter(
                image: photoImage,
                srcRect: photoSrcRect,
              ),
            ),
          )
        : Center(
            child: Text(
              widget.text ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: widget.fontSize,
                color: widget.fontColor,
                letterSpacing: -0.5,
              ),
            ),
          );

    Widget content = Material(
      shape: shape,
      color: color,
      clipBehavior: Clip.antiAlias,
      elevation: isIOS ? 0 : 2,
      child: InkWell(
        onTap: widget.onPressed,
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapEnd(),
        onTapCancel: _onTapEnd,
        borderRadius: BorderRadius.circular(radius),
        child: tileContent,
      ),
    );

    if (isIOS) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    final child = AppMotion.disableAnimations(context)
        ? content
        : ScaleTransition(scale: _scaleAnimation, child: content);

    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: widget.text != null
          ? l10n.tileLabel(widget.text!)
          : l10n.emptyTileLabel,
      button: widget.onPressed != null,
      child: Padding(
        padding: EdgeInsets.all(tilePadding),
        child: child,
      ),
    );
  }
}

/// Paints one fixed slice of a shared photo-mode image into a tile.
class _PhotoTilePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  const _PhotoTilePainter({required this.image, required this.srcRect});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      srcRect,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _PhotoTilePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.srcRect != srcRect;
}
