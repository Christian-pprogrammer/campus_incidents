import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/services/photo_storage.dart';

/// Loads one incident photo from Firestore and shows [placeholder] while it
/// loads or if it is missing.
class IncidentPhoto extends StatelessWidget {
  const IncidentPhoto({
    super.key,
    required this.incidentId,
    required this.index,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String incidentId;
  final int index;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: context.read<PhotoStorage>().load(incidentId, index),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return placeholder;
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => placeholder,
        );
      },
    );
  }
}
