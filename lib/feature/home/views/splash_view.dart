import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_scaffold.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:care_circle/feature/home/providers/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsync = ref.watch(residentsProvider);

    return AppScaffold(
      scrollable: false,
      body: Center(
        child: residentsAsync.when(
          data: (_) =>
              const CircularProgressIndicator(color: AppColors.primary),
          loading: () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSizes.lg),
              AppText.secondary('Getting things ready…'),
            ],
          ),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                color: AppColors.statusUnknown,
                size: AppSizes.iconLg,
              ),
              const SizedBox(height: AppSizes.md),
              AppText.body("Couldn't load your family list."),
              const SizedBox(height: AppSizes.sm),
              ElevatedButton(
                onPressed: () => ref.invalidate(residentsProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
