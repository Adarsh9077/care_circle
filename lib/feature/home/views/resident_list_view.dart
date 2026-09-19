import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/routers/route_names.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/utils/reassurance_visuals.dart';
import 'package:care_circle/core/widgets/app_scaffold.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:care_circle/feature/home/providers/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResidentListView extends ConsumerWidget {
  const ResidentListView({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsync = ref.watch(residentsProvider);

    return AppScaffold(
      scrollable: false,
      padding: EdgeInsets.zero, // slivers below own their own padding
      onRefresh: () => ref.refresh(residentsProvider.future),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.secondary(_greeting()),
                  const SizedBox(height: 2),
                  const AppText.h1('Your family'),
                ],
              ),
            ),
          ),
          residentsAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              sliver: SliverList.separated(
                itemCount: 2,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.md),
                itemBuilder: (_, __) => const _ResidentTileSkeleton(),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: AppColors.statusUnknown,
                        size: AppSizes.iconLg,
                      ),
                      const SizedBox(height: AppSizes.md),
                      const AppText.body("Couldn't load your family list."),
                      const SizedBox(height: AppSizes.sm),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(residentsProvider),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (residents) => residents.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: _EmptyResidents()),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      0,
                      AppSizes.lg,
                      AppSizes.xl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: residents.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSizes.md),
                      itemBuilder: (_, i) =>
                          _ResidentTile(resident: residents[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResidentTile extends ConsumerWidget {
  final Resident resident;
  const _ResidentTile({required this.resident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider(resident.id));
    final visual = reassuranceVisual(
      summaryAsync.asData?.value?.reassuranceState,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      onTap: () => context.push('${RouteNames.residentHome}/${resident.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: AppSizes.avatarMd / 2,
                  backgroundColor: AppColors.primaryLight,
                  child: AppText.body(
                    resident.avatarInitials,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: visual.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h3(resident.name),
                  const SizedBox(height: 2),
                  AppText.secondary(
                    '${resident.relationship} · ${resident.facility.city}',
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Icon(visual.icon, size: 14, color: visual.color),
                      const SizedBox(width: 4),
                      AppText.caption(
                        visual.label,
                        color: visual.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ResidentTileSkeleton extends StatelessWidget {
  const _ResidentTileSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    decoration: BoxDecoration(
      color: AppColors.shimmerBase,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    ),
  );
}

class _EmptyResidents extends StatelessWidget {
  const _EmptyResidents();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSizes.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.people_outline,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSizes.md),
        const AppText.body('No family members linked to your account yet.'),
      ],
    ),
  );
}
