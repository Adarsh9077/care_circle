import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Thin wrapper so text styling stays centralized and consistent.
class AppText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? fontWeight;

  const AppText(
    this.data, {
    super.key,
    this.style = AppTextStyles.bodyMedium,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  });

  const AppText.h1(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  }) : style = AppTextStyles.h1;
  const AppText.h2(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  }) : style = AppTextStyles.h2;
  const AppText.h3(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  }) : style = AppTextStyles.h3;
  const AppText.body(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  }) : style = AppTextStyles.bodyLarge;
  const AppText.secondary(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  }) : style = AppTextStyles.bodySecondary;
  const AppText.caption(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontWeight,
  }) : style = AppTextStyles.caption;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style.copyWith(
        color: color ?? style.color,
        fontWeight: fontWeight ?? style.fontWeight,
      ),
    );
  }
}
