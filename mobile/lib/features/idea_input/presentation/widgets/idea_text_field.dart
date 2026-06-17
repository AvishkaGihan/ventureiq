import 'package:flutter/material.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';
import 'package:ventureiq_app/core/theme/app_spacing.dart';
import 'package:ventureiq_app/core/theme/app_typography.dart';
import 'package:ventureiq_app/features/idea_input/presentation/widgets/voice_input_button.dart';

/// Generous multiline business idea field with blur validation.
class IdeaTextField extends StatefulWidget {
  const IdeaTextField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<IdeaTextField> createState() => _IdeaTextFieldState();
}

class _IdeaTextFieldState extends State<IdeaTextField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _hasBlurred = false;
  bool _isFocused = false;
  String _baseText = '';
  int _baseSelectionOffset = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant IdeaTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (!_focusNode.hasFocus) {
        _hasBlurred = true;
      }
    });
  }

  void _handleDictationStart() {
    _baseText = _controller.text;
    _baseSelectionOffset = _controller.selection.baseOffset;
    if (_baseSelectionOffset < 0) {
      _baseSelectionOffset = _baseText.length;
    }
  }

  void _handleTranscription(String text) {
    if (text.isEmpty) return;
    
    String beforeCursor = _baseText.substring(0, _baseSelectionOffset);
    String afterCursor = _baseText.substring(_baseSelectionOffset);
    
    final separator = beforeCursor.isNotEmpty && !beforeCursor.endsWith(' ') && !beforeCursor.endsWith('\n') ? ' ' : '';
    final insertedText = separator + text;
    
    final newText = beforeCursor + insertedText + afterCursor;
    final newCursorPos = _baseSelectionOffset + insertedText.length;
    
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    widget.onChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    final trimmedLength = widget.value.trim().length;
    final showError = _hasBlurred && trimmedLength > 0 && trimmedLength < 10;
    final characterCount = widget.value.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.surface200,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: showError
                  ? AppColors.error
                  : _isFocused
                  ? AppColors.electricViolet
                  : AppColors.surface300,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.electricViolet.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Semantics(
            label:
                'Business idea input field. Type your idea and tap Validate.',
            textField: true,
            child: TextField(
              key: const ValueKey('ideaTextField'),
              controller: _controller,
              focusNode: _focusNode,
              minLines: 5,
              maxLines: 8,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              cursorColor: AppColors.electricViolet,
              decoration: InputDecoration(
                hintText: 'Describe your business idea...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.space4),
                suffixIcon: VoiceInputButton(
                  onDictationStart: _handleDictationStart,
                  onTranscription: _handleTranscription,
                ),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Row(
          children: [
            Expanded(
              child: showError
                  ? Text(
                      'Tell us a bit more about your idea',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              '$characterCount ${characterCount == 1 ? 'character' : 'characters'}',
              textAlign: TextAlign.right,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
