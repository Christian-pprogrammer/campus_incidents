import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/providers/incident_provider.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/screens/auth_gate.dart';
import 'package:campus_incidents/services/auth_service.dart';
import 'package:campus_incidents/services/incident_repository.dart';
import 'package:campus_incidents/services/photo_storage.dart';
import 'package:campus_incidents/services/user_repository.dart';

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<IncidentRepository>(create: (_) => IncidentRepository()),
        Provider<PhotoStorage>(create: (_) => PhotoStorage()),
        ChangeNotifierProvider<SessionProvider>(
          create: (context) => SessionProvider(
            authService: context.read<AuthService>(),
            users: context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProxyProvider<SessionProvider, IncidentProvider>(
          create: (context) => IncidentProvider(
            repository: context.read<IncidentRepository>(),
          ),
          update: (_, session, incidents) => incidents!..bindUser(session.profile),
        ),
      ],
      child: MaterialApp(
        title: 'CampusCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}
