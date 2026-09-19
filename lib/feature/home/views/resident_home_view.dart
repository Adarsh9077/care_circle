import 'package:care_circle/feature/home/widgets/check_in_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:care_circle/core/routers/route_names.dart';
import 'package:care_circle/core/widgets/app_scaffold.dart';
import 'package:care_circle/core/widgets/privacy_badge.dart';
import 'package:care_circle/feature/home/providers/home_providers.dart';
import 'package:care_circle/feature/home/widgets/reassurance_card.dart';
import 'package:care_circle/feature/home/widgets/see_today_section.dart';

class ResidentHomeView extends ConsumerWidget {
  final String residentId;
  const ResidentHomeView({super.key, required this.residentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resident = ref.watch(residentByIdProvider(residentId));
    final summaryAsync = ref.watch(dailySummaryProvider(residentId));
    final eventsAsync = ref.watch(careEventsProvider(residentId));
    final multipleResidents =
        (ref.watch(residentsProvider).asData?.value.length ?? 1) > 1;

    return AppScaffold(
      appBar: AppBar(
        title: AppText.h3(resident?.name ?? 'Resident'),
        leading: multipleResidents
            ? BackButton(onPressed: () => context.go(RouteNames.residents))
            : null,
      ),
      onRefresh: () async {
        ref.invalidate(dailySummaryProvider(residentId));
        ref.invalidate(careEventsProvider(residentId));
        await ref.read(dailySummaryProvider(residentId).future);
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryAsync.when(
            loading: () => const _CardSkeleton(),
            error: (e, _) => ReassuranceCard(
              summary: null,
              residentName: resident?.name ?? 'They',
            ),
            data: (summary) => ReassuranceCard(
              summary: summary,
              residentName: resident?.name ?? 'They',
            ),
          ),
          if (resident != null) ...[
            const SizedBox(height: AppSizes.md),
            PrivacyBadge(
              level: resident.sharingPreferences.shareStaffNotes == 'none'
                  ? SharingLevel.hidden
                  : SharingLevel.limited,
              label: 'Some updates stay private to ${resident.name}',
            ),
          ],
          const SizedBox(height: AppSizes.xl),
          eventsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) =>
                AppText.secondary("Recent activity isn't available right now."),
            data: (_) => SeeTodaySection(
              events: ref.watch(familyVisibleCareEventsProvider(residentId)),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  showCheckInSheet(context, residentId: residentId),
              child: const Text('Request a check-in'),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.push('${RouteNames.residentHome}/$residentId/week'),
            child: const Text('See this week'),
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    decoration: BoxDecoration(
      color: AppColors.shimmerBase,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    ),
  );
}
