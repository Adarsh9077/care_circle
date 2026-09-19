import 'package:care_circle/core/models/care_circle_models.dart';
import 'package:care_circle/core/providers/care_circle_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckInNotifier extends AsyncNotifier<CheckInRequest?> {
  CheckInNotifier(this.residentId);

  final String residentId;

  @override
  Future<CheckInRequest?> build() async {
    return null;
  }

  Future<void> submit({required String reason, required String urgency}) async {
    state = const AsyncLoading();

    final service = ref.read(careCircleServiceProvider);

    state = await AsyncValue.guard(() async {
      final envelope = await service.createCheckInRequest(
        CheckInRequestInput(
          residentId: residentId,
          reason: reason,
          urgency: urgency,
        ),
      );

      return envelope.data;
    });
  }
}

final checkInNotifierProvider =
    AsyncNotifierProvider.family<CheckInNotifier, CheckInRequest?, String>(
      CheckInNotifier.new,
    );
