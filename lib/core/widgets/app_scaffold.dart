import 'package:care_circle/core/theme/app_colors.dart';
import 'package:care_circle/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Future<void> Function()? onRefresh;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool scrollable;
  final EdgeInsets padding;
  final bool bottomSafeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.onRefresh,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.bottomSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primary,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(bottom: bottomSafeArea, child: content),
    );
  }
}
