import 'package:flutter/material.dart';

import 'package:campus_incidents/core/theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Text(
          'CampusCare',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
      ],
    );
  }
}
