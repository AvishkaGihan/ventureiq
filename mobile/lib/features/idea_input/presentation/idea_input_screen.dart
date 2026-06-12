import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';
import 'package:ventureiq_app/core/widgets/error_card.dart';
import 'package:ventureiq_app/features/idea_input/presentation/idea_input_notifier.dart';
import 'package:ventureiq_app/features/idea_input/presentation/idea_input_providers.dart';
import 'package:ventureiq_app/features/idea_input/presentation/widgets/context_expander.dart';
import 'package:ventureiq_app/features/idea_input/presentation/widgets/idea_text_field.dart';

/// Main idea input screen for starting a VentureIQ validation.
class IdeaInputScreen extends ConsumerWidget {
  const IdeaInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(ideaInputNotifierProvider, (previous, next) {
      final state = next.value;
      final previousIdeaId = previous?.value?.submittedIdeaId;
      if (state?.plausibilityResult?.verdict == 'pass' &&
          state?.submittedIdeaId != null &&
          previousIdeaId != state?.submittedIdeaId &&
          context.mounted) {
        context.go('/home/war-room/${state!.submittedIdeaId}');
      }
    });

    final asyncState = ref.watch(ideaInputNotifierProvider);
    final formState = asyncState.value ?? const IdeaInputState();
    final notifier = ref.read(ideaInputNotifierProvider.notifier);
    final canValidate = formState.ideaText.trim().length >= 10;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            AppSpacing.space6,
            AppSpacing.space4,
            AppSpacing.space6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What are we validating?',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.space5),
              IdeaTextField(
                value: formState.ideaText,
                onChanged: notifier.updateIdeaText,
              ),
              const SizedBox(height: AppSpacing.space4),
              _PlausibilityFeedback(
                state: formState,
                asyncState: asyncState,
                onRetry: notifier.submit,
              ),
              ContextExpander(
                isExpanded: formState.isContextExpanded,
                onToggle: notifier.toggleContextExpanded,
                onTargetAudienceChanged: notifier.updateTargetAudience,
                onIndustryChanged: notifier.updateIndustry,
                onMonetizationModelChanged: notifier.updateMonetizationModel,
                onRegionChanged: notifier.updateRegion,
              ),
              const SizedBox(height: AppSpacing.space6),
              _ValidateButton(
                isLoading: asyncState.isLoading,
                isEnabled: canValidate,
                onPressed: notifier.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlausibilityFeedback extends StatelessWidget {
  const _PlausibilityFeedback({
    required this.state,
    required this.asyncState,
    required this.onRetry,
  });

  final IdeaInputState state;
  final AsyncValue<IdeaInputState> asyncState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (asyncState.hasError && !asyncState.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space4),
        child: ErrorCard(
          type: FeedbackType.error,
          message: 'Something went wrong while validating your idea.',
          onRetry: onRetry,
        ),
      );
    }

    final result = state.plausibilityResult;
    if (result == null || result.verdict == 'pass') {
      return const SizedBox.shrink();
    }

    final FeedbackType type;
    final String message;
    if (result.verdict == 'refine') {
      type = FeedbackType.info;
      message =
          result.guidance?.join('\n') ??
          'Add a little more context and try validating again.';
    } else {
      type = FeedbackType.error;
      message = result.reason ?? 'This idea is not ready to validate yet.';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: ErrorCard(type: type, message: message),
    );
  }
}

class _ValidateButton extends StatelessWidget {
  const _ValidateButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Validate',
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.electricViolet,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.surface300,
            disabledForegroundColor: AppColors.textSecondary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Text('Validate'),
        ),
      ),
    );
  }
}
