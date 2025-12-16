import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isAdmin ? scheme.primary : scheme.tertiary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (isAdmin ? scheme.primary : scheme.tertiary).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isAdmin ? Icons.security : Icons.school, // changed from Icons.shield_person

              size: 16, color: isAdmin ? scheme.primary : scheme.tertiary),
          const SizedBox(width: 6),
          Text(role.toUpperCase(),
              style: TextStyle(
                color: isAdmin ? scheme.primary : scheme.tertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              )),
        ],
      ),
    );
  }
}