import 'package:care_circle/core/widgets/app_input_field.dart';
import 'package:care_circle/feature/home/notifiers/check_in_notifier.dart';
import 'package:flutter/material.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:care_circle/core/widgets/app_text.dart';
import 'package:care_circle/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showCheckInSheet(
  BuildContext context, {
  required String residentId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => CheckInSheet(residentId: residentId),
  );
}

class CheckInSheet extends ConsumerStatefulWidget {
  final String residentId;
  const CheckInSheet({super.key, required this.residentId});

  @override
  ConsumerState<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<CheckInSheet> {
  final _reasonController = TextEditingController();
  String _urgency = 'routine';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInNotifierProvider(widget.residentId));

    ref.listen(checkInNotifierProvider(widget.residentId), (prev, next) {
      if (next.hasValue && next.value != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Staff have been notified. Someone will follow up soon.',
            ),
          ),
        );
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h3('Request a check-in'),
          const SizedBox(height: AppSizes.sm),
          AppText.secondary(
            'Staff will look in and let you know how things are.',
          ),
          const SizedBox(height: AppSizes.lg),
          AppInputField(
            controller: _reasonController,
            label: 'What would you like staff to check on?',
            hint: "e.g. Hasn't answered calls today",
            maxLines: 3,
            errorText: state.hasError ? 'Please tell us a reason.' : null,
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Routine'),
                selected: _urgency == 'routine',
                onSelected: (_) => setState(() => _urgency = 'routine'),
              ),
              const SizedBox(width: AppSizes.sm),
              ChoiceChip(
                label: const Text('Soon'),
                selected: _urgency == 'soon',
                onSelected: (_) => setState(() => _urgency = 'soon'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => ref
                        .read(
                          checkInNotifierProvider(widget.residentId).notifier,
                        )
                        .submit(
                          reason: _reasonController.text,
                          urgency: _urgency,
                        ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send request'),
            ),
          ),
        ],
      ),
    );
  }
}
