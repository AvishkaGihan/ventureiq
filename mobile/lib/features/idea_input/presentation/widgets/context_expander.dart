import 'package:flutter/material.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';

/// Optional context fields for improving plausibility analysis.
class ContextExpander extends StatelessWidget {
  const ContextExpander({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onTargetAudienceChanged,
    required this.onIndustryChanged,
    required this.onMonetizationModelChanged,
    required this.onRegionChanged,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onTargetAudienceChanged;
  final ValueChanged<String> onIndustryChanged;
  final ValueChanged<String> onMonetizationModelChanged;
  final ValueChanged<String> onRegionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            button: true,
            label: 'Add context optional',
            child: TextButton.icon(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
              ),
              icon: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              label: Text(
                'Add context (optional)',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  children: [
                    const SizedBox(height: AppSpacing.space2),
                    _ContextField(
                      label: 'Target Audience',
                      hintText: 'Who needs this most?',
                      onChanged: onTargetAudienceChanged,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    _ContextField(
                      label: 'Industry',
                      hintText: 'Healthcare, fintech, education...',
                      onChanged: onIndustryChanged,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    _ContextField(
                      label: 'Monetization Model',
                      hintText: 'Subscription, marketplace fee, ads...',
                      onChanged: onMonetizationModelChanged,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    _ContextField(
                      label: 'Region',
                      hintText: 'Sri Lanka, US, global...',
                      onChanged: onRegionChanged,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ContextField extends StatelessWidget {
  const _ContextField({
    required this.label,
    required this.hintText,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label field',
      textField: true,
      child: TextField(
        minLines: 1,
        maxLines: 1,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.electricViolet,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          fillColor: AppColors.surface200,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.surface300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.surface300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(
              color: AppColors.electricViolet,
              width: 2,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
