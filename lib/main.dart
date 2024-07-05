import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_management_app/firebase_options.dart';
import 'package:task_management_app/services/authentication.dart';
import 'package:task_management_app/services/navigation.dart';
import 'package:task_management_app/services/push_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Defer the first frame until `FlutterNativeSplash.remove()` is called
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(StreamBuilder<bool>(
    // Listen to the auth state changes
    stream: AuthenticationService().authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.active) {
        // Keep splash screen until auth state is ready
        return const SizedBox.shrink();
      }

      // Error might occur due to incorrect credentials, token refresh failures, revoked sessions, network failures, misconfigured Firebase settings, etc.
      if (snapshot.hasError) {
        debugPrint('Auth Error: ${snapshot.error}');
      }
      // Remove splash screen once auth state is initialized
      FlutterNativeSplash.remove();
      debugPrint('Auth state changed to ${snapshot.data}');

      // Rebuild app to update the route based on the auth state. Do NOT use `const` here.
      return MyApp(key: ValueKey(snapshot.data));
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        Provider<PushMessagingService>(
          create: (_) => PushMessagingService(),
        ),
      ],
      child: MaterialApp.router(
        // theme: ThemeData.light().copyWith(
        //   colorScheme: ColorScheme.fromSeed(
        //     seedColor: Colors.green,
        //   ),
        // ),
        routerConfig: routerConfig,
        restorationScopeId: 'app',
      ),
    );
  }
}
