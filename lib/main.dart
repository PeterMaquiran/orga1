import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/data/seed.dart';
import 'package:orga1/ui/screen/ios/auth/email_confirmation.dart';
import 'package:orga1/ui/screen/ios/auth/login.dart';
import 'package:orga1/ui/screen/ios/boards/boards_screen.dart';
import 'package:orga1/ui/screen/ios/calendar/calendar.dart';
import 'package:orga1/ui/screen/ios/home/home.dart';
import 'package:orga1/ui/shared/theme/appColors.dart';

// 1. Define your Route "Map" (The Central Command)
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const OrgaLoginScreen(),
    ),
    GoRoute(
      path: '/confirm-email',
      builder: (context, state) => const EmailConfirmationScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/boards',
      builder: (context, state) => const BoardsScreen(),
    ),
  ],
);

Future<void> main() async {
  // 1. Initialize local persistent engines
  await Hive.initFlutter();

  // 2. Open standard map containers
  final habitBox = await Hive.openBox('habitsBox');
  final eventBox = await Hive.openBox('habitEventsBox');
  await Hive.openBox('calendarEventsBox');

  // 3. RUN SEEDER: Processes your mock data onto disk smoothly
  await HabitSeeder.seedIfEmpty(habitBox: habitBox, eventBox: eventBox);
  runApp(const OrgaApp());
}

class OrgaApp extends StatelessWidget {
  const OrgaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Use .router constructor to connect your Map to the App
    return MaterialApp.router(
      theme: appTheme,
      routerConfig: _router,
      title: 'Orga',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.light),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
