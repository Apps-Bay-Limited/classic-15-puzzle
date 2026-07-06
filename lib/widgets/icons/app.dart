import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    return Semantics(
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          shape: const CircleBorder(),
          elevation: 4.0,
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Text(
              '15',
              style: (Theme.of(context).primaryTextTheme.bodyLarge ?? const TextStyle()).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
