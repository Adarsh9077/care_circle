import 'package:care_circle/core/routers/app_router_refresh.dart';
import 'package:care_circle/core/routers/route_names.dart';
import 'package:care_circle/feature/home/providers/home_providers.dart';
import 'package:care_circle/feature/home/views/resident_home_view.dart';
import 'package:care_circle/feature/home/views/resident_list_view.dart';
import 'package:care_circle/feature/home/views/resident_week_view.dart';
import 'package:care_circle/feature/home/views/splash_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final residentsAsync = ref.read(residentsProvider);
      final currentPath = state.matchedLocation;
      final isAtSplash = currentPath == RouteNames.splash;

      if (residentsAsync is AsyncLoading) {
        return isAtSplash ? null : RouteNames.splash;
      }
      if (residentsAsync.hasError) {
        return null; // splash screen shows its own retry UI
      }

      final residents = residentsAsync.asData?.value ?? const [];

      if (isAtSplash) {
        if (residents.length == 1) {
          return '${RouteNames.residentHome}/${residents.first.id}';
        }
        return RouteNames.residents;
      }
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splash, builder: (c, s) => const SplashView()),
      GoRoute(
        path: RouteNames.residents,
        builder: (c, s) => const ResidentListView(),
      ),
      GoRoute(
        path: '${RouteNames.residentHome}/:residentId',
        builder: (c, s) =>
            ResidentHomeView(residentId: s.pathParameters['residentId']!),
      ),
      GoRoute(
        path: '${RouteNames.residentHome}/:residentId/week',
        builder: (c, s) =>
            ResidentWeekView(residentId: s.pathParameters['residentId']!),
      ),
    ],
  );
});
