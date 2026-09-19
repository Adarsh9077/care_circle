import 'package:care_circle/core/services/care_circle_mock_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final careCircleServiceProvider = Provider<CareCircleMockService>((ref) {
  return CareCircleMockService();
});
