import 'dart:ui';
import 'package:flutter/material.dart' hide Chip;

class ChipWidget extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color overlayColor;
  final Color backgroundColor;
  final Color fontColor;
  final double fontSize;
  final double size;

  const ChipWidget(
    this.text,
    this.overlayColor,
    this.backgroundColor,
    this.fontColor,
    this.fontSize, {
    super.key,
    this.onPressed,
    required this.size,
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

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.size < 150;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final radius = isCompact ? 12.0 : 16.0;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );

    var color = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (isIOS) {
      color = color.withValues(alpha: 0.7);
    }
    color = Color.alphaBlend(widget.backgroundColor, color);
    color = Color.alphaBlend(widget.overlayColor, color);

    Widget content = Material(
      shape: shape,
      color: color,
      elevation: isIOS ? 0 : 2,
      child: InkWell(
        onTap: widget.onPressed,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        borderRadius: BorderRadius.circular(radius),
        child: Center(
          child: Text(
            widget.text ?? "",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: widget.fontSize,
              color: widget.fontColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );

    if (isIOS) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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

    return Semantics(
      label: widget.text != null ? "Tile ${widget.text}" : "Empty tile",
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 3.0 : 6.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: content,
        ),
      ),
    );
  }
}
