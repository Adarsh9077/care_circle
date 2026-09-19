import 'package:care_circle/core/routers/app_router.dart';
import 'package:care_circle/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CareCircleApp()));
}

class CareCircleApp extends ConsumerWidget {
  const CareCircleApp({super.key});

  // @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CareCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
