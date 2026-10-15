import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_paths.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = location.startsWith(RoutePaths.profile) ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(
          i == 0 ? RoutePaths.companies : RoutePaths.profile,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.domain_outlined),
            selectedIcon: Icon(Icons.domain),
            label: 'Companies',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
