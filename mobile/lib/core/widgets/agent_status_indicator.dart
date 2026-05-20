import 'package:flutter/material.dart';

import 'package:ventureiq_app/core/constants/enums.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';

/// Visual variant for the [AgentStatusIndicator].
enum AgentStatusVariant {
  /// Compact horizontal pill — agent-colored bg, phase icon + text. ~24dp.
  badge,

  /// Full-width row — agent icon + name + phase icon + text + animated indicator. ~48dp.
  full,

  /// Minimal 12dp colored dot — pulsing for active phases, solid for terminal.
  dot,
}

/// Multi-phase agent lifecycle status indicator.
///
/// Displays the current processing phase of an AI agent with agent-specific
/// identity colors. Supports three visual variants: badge, full, and dot.
///
/// Active phases (started, searching, analyzing, crossReferencing) pulse
/// in the dot variant. Terminal phases (complete, error) show solid.
/// Respects Reduce Motion preferences.
class AgentStatusIndicator extends StatelessWidget {
  /// Creates an agent status indicator.
  const AgentStatusIndicator({
    super.key,
    required this.phase,
    required this.agent,
    this.variant = AgentStatusVariant.badge,
  });

  /// Current processing phase of the agent.
  final AgentPhase phase;

  /// The agent whose status is being displayed.
  final AgentRole agent;

  /// Visual variant of the indicator.
  final AgentStatusVariant variant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${agent.displayName} agent status: ${phase.displayName}',
      excludeSemantics: true,
      child: _buildVariant(context),
    );
  }

  Widget _buildVariant(BuildContext context) {
    switch (variant) {
      case AgentStatusVariant.badge:
        return _BadgeVariant(phase: phase, agent: agent);
      case AgentStatusVariant.full:
        return _FullVariant(phase: phase, agent: agent);
      case AgentStatusVariant.dot:
        return _DotVariant(phase: phase, agent: agent);
    }
  }
}

class _BadgeVariant extends StatelessWidget {
  const _BadgeVariant({
    required this.phase,
    required this.agent,
  });

  final AgentPhase phase;
  final AgentRole agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: agent.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phase.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(
            phase.displayName,
            style: AppTypography.micro.copyWith(
              color: agent.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullVariant extends StatelessWidget {
  const _FullVariant({
    required this.phase,
    required this.agent,
  });

  final AgentPhase phase;
  final AgentRole agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          Text(
            agent.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              agent.displayName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTypography.bodySm.copyWith(
                color: agent.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Text(
            phase.icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: AppSpacing.space1),
          Flexible(
            child: Text(
              phase.displayName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTypography.bodySm.copyWith(
                color: agent.color,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          _PulsingDot(
            color: agent.color,
            isActive: phase.isActive,
            size: 10,
          ),
        ],
      ),
    );
  }
}

class _DotVariant extends StatelessWidget {
  const _DotVariant({
    required this.phase,
    required this.agent,
  });

  final AgentPhase phase;
  final AgentRole agent;

  @override
  Widget build(BuildContext context) {
    return _PulsingDot(
      color: agent.color,
      isActive: phase.isActive,
      size: 12,
    );
  }
}

/// Animated pulsing dot that fades between 0.4 and 1.0 opacity.
///
/// Only pulses when [isActive] is true. Respects Reduce Motion.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
    required this.isActive,
    this.size = 12,
  });

  final Color color;
  final bool isActive;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant _PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.isActive && !reduceMotion) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isActive ? _animation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
