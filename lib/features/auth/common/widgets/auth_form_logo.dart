import 'package:flutter/material.dart';

class AuthFormLogo extends StatelessWidget {
  final IconData icon;

  const AuthFormLogo({
    super.key,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
