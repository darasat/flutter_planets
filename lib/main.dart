import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/presentation/home_page.dart';
import 'features/planets/presentation/planets_page.dart';
import 'features/planets/presentation/planet_detail_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Planetas App',
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/planets', builder: (context, state) => const PlanetsPage()),
    GoRoute(path: '/planets/:planetId', builder: (context, state) {
      final planetId = state.pathParameters['planetId']!;
      return PlanetDetailPage(planetId: planetId);
    }),
  ],
);
