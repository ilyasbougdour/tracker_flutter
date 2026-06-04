import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/app_providers.dart';
import '../application/auth_controller.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/dashboard/dashboard_page.dart';
import '../presentation/fuel/fuel_page.dart';
import '../presentation/maintenance/maintenance_page.dart';
import '../presentation/shared/app_shell.dart';
import '../presentation/vehicles/vehicles_page.dart';

final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((Ref ref) {
  final AuthState authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final bool isLogin = state.uri.path == '/login';

      if (!authState.isAuthenticated && !isLogin) {
        return '/login';
      }

      if (authState.isAuthenticated && isLogin) {
        return '/dashboard';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/vehicles',
            builder: (context, state) => const VehiclesPage(),
          ),
          GoRoute(path: '/fuel', builder: (context, state) => const FuelPage()),
          GoRoute(
            path: '/maintenance',
            builder: (context, state) => const MaintenancePage(),
          ),
        ],
      ),
    ],
  );
});
