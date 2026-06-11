import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/local_store.dart';
import 'services/step_service.dart';
import 'state/activity_state.dart';
import 'state/content_state.dart';
import 'state/session_state.dart';
import 'state/settings_state.dart';
import 'screens/onboarding/splash_screen.dart';
import 'theme/app_theme.dart';

/// Realtime Database URL for the Campus Fit Firebase project. The region-scoped
/// URL must be set explicitly because `google-services.json` does not carry it.
const String dbUrl =
    'https://campusfit-8a1d7-default-rtdb.asia-southeast1.firebasedatabase.app/';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Point the Realtime Database at the correct regional instance.
  final database = FirebaseDatabase.instance;
  database.databaseURL = dbUrl;

  final localStore = await LocalStore.create();
  final authService = AuthService(FirebaseAuth.instance);
  final databaseService = DatabaseService(database);
  final stepService = StepService();

  log('Firebase initialised for ${Firebase.app().options.projectId}',
      name: 'main');

  runApp(CampusFitApp(
    localStore: localStore,
    authService: authService,
    databaseService: databaseService,
    stepService: stepService,
  ));
}

class CampusFitApp extends StatelessWidget {
  const CampusFitApp({
    super.key,
    required this.localStore,
    required this.authService,
    required this.databaseService,
    required this.stepService,
  });

  final LocalStore localStore;
  final AuthService authService;
  final DatabaseService databaseService;
  final StepService stepService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsState(localStore),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionState(
            auth: authService,
            database: databaseService,
            store: localStore,
          ),
        ),
        // Activity + content states follow the signed-in user via proxy
        // providers, so cloud data is pulled when the uid changes.
        ChangeNotifierProxyProvider<SessionState, ActivityState>(
          create: (_) => ActivityState(
            stepService: stepService,
            database: databaseService,
            store: localStore,
          ),
          update: (_, session, activity) {
            activity!.attachUser(session.uid);
            return activity;
          },
        ),
        ChangeNotifierProxyProvider<SessionState, ContentState>(
          create: (_) => ContentState(
            database: databaseService,
            store: localStore,
          ),
          update: (_, session, content) {
            content!.attachUser(
              uid: session.uid,
              displayName: session.session.displayName ?? 'You',
            );
            return content;
          },
        ),
      ],
      child: Consumer<SettingsState>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Campus Fit',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
