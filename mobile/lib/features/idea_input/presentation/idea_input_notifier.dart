import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ventureiq_app/features/idea_input/data/idea_repository.dart';
import 'package:ventureiq_app/features/idea_input/domain/plausibility_entity.dart';
import 'package:ventureiq_app/features/idea_input/presentation/idea_input_providers.dart';

part 'idea_input_notifier.freezed.dart';

/// Immutable form state for the idea input screen.
@freezed
abstract class IdeaInputState with _$IdeaInputState {
  const factory IdeaInputState({
    @Default('') String ideaText,
    @Default('') String targetAudience,
    @Default('') String industry,
    @Default('') String monetizationModel,
    @Default('') String region,
    @Default(false) bool isContextExpanded,
    PlausibilityEntity? plausibilityResult,
    String? submittedIdeaId,
  }) = _IdeaInputState;
}

/// Riverpod notifier that manages idea form state and API submission.
class IdeaInputNotifier extends AsyncNotifier<IdeaInputState> {
  late IdeaRepository _ideaRepository;

  @override
  FutureOr<IdeaInputState> build() {
    _ideaRepository = ref.read(ideaRepositoryProvider);
    return const IdeaInputState();
  }

  /// Whether the current idea text satisfies the client-side minimum.
  bool get canValidate {
    final current = state.value ?? const IdeaInputState();
    return current.ideaText.trim().length >= 10;
  }

  void updateIdeaText(String value) {
    _update(
      (current) => current.copyWith(
        ideaText: value,
        plausibilityResult: null,
        submittedIdeaId: null,
      ),
    );
  }

  void updateTargetAudience(String value) {
    _update((current) => current.copyWith(targetAudience: value));
  }

  void updateIndustry(String value) {
    _update((current) => current.copyWith(industry: value));
  }

  void updateMonetizationModel(String value) {
    _update((current) => current.copyWith(monetizationModel: value));
  }

  void updateRegion(String value) {
    _update((current) => current.copyWith(region: value));
  }

  void toggleContextExpanded() {
    _update(
      (current) {
        final isExpanded = !current.isContextExpanded;
        return current.copyWith(
          isContextExpanded: isExpanded,
          targetAudience: isExpanded ? current.targetAudience : '',
          industry: isExpanded ? current.industry : '',
          monetizationModel: isExpanded ? current.monetizationModel : '',
          region: isExpanded ? current.region : '',
        );
      },
    );
  }

  /// Submit the idea, then run the plausibility check sequentially.
  Future<void> submit() async {
    final previous = state;
    final current = previous.value ?? const IdeaInputState();
    if (current.ideaText.trim().length < 10) {
      return;
    }

    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<IdeaInputState>().copyWithPrevious(previous);

    try {
      final String ideaId;
      if (current.submittedIdeaId != null) {
        ideaId = current.submittedIdeaId!;
      } else {
        final idea = await _ideaRepository.createIdea(
          ideaText: current.ideaText.trim(),
          targetAudience: current.targetAudience,
          industry: current.industry,
          monetizationModel: current.monetizationModel,
          region: current.region,
        );
        ideaId = idea.id;
      }
      final plausibility = await _ideaRepository.checkPlausibility(ideaId);

      state = AsyncData(
        current.copyWith(
          ideaText: current.ideaText.trim(),
          plausibilityResult: plausibility,
          submittedIdeaId: ideaId,
        ),
      );
    } catch (error, stackTrace) {
      final errorState = AsyncValue<IdeaInputState>.error(error, stackTrace);
      // ignore: invalid_use_of_internal_member
      state = errorState.copyWithPrevious(previous);
    }
  }

  void _update(IdeaInputState Function(IdeaInputState current) update) {
    final current = state.value ?? const IdeaInputState();
    state = AsyncData(update(current));
  }
}
