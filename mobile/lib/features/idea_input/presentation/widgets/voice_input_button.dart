import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ventureiq_app/core/theme/app_colors.dart';

/// A button that manages speech-to-text input.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onTranscription,
    this.onDictationStart,
    this.isEnabled = true,
    this.speechToText,
  });

  final void Function(String text) onTranscription;
  final VoidCallback? onDictationStart;
  final bool isEnabled;
  final SpeechToText? speechToText;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  bool _isInitializing = false;
  late final SpeechToText _speechToText;
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speechToText = widget.speechToText ?? SpeechToText();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnabled && !widget.isEnabled) {
      _stopListening();
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSpeechError(SpeechRecognitionError error) {
    _stopListening();
    if (!mounted) return;

    String friendlyMessage = 'Speech recognition error. Please try again.';
    final msg = error.errorMsg.toLowerCase();
    if (msg.contains('network') || msg.contains('internet')) {
      friendlyMessage = 'Network error. Please check your connection and try again.';
    } else if (msg.contains('permission') || msg.contains('denied')) {
      friendlyMessage = 'Microphone permission denied. Please enable it in Settings.';
    } else if (msg.contains('no match') || msg.contains('speech_timeout')) {
      friendlyMessage = 'Could not hear anything. Please speak clearly and try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendlyMessage),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    if (status == 'done' || status == 'notListening') {
      _stopListening();
    } else if (status == 'listening') {
      setState(() {});
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    if (result.recognizedWords.isNotEmpty) {
      widget.onTranscription(result.recognizedWords);
    }
  }

  Future<void> _toggleListening() async {
    if (_isInitializing) return;
    if (_speechToText.isListening) {
      _stopListening();
      return;
    }

    _isInitializing = true;
    bool available = false;
    try {
      available = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );
    } catch (e) {
      if (mounted) _onSpeechError(SpeechRecognitionError(e.toString(), true));
    } finally {
      _isInitializing = false;
    }

    if (available) {
      if (mounted) {
        setState(() {});
        widget.onDictationStart?.call();
        if (!MediaQuery.disableAnimationsOf(context)) {
          _animationController.repeat(reverse: true);
        }
      }
      try {
        await _speechToText.listen(onResult: _onSpeechResult);
      } catch (e) {
        if (mounted) _onSpeechError(SpeechRecognitionError(e.toString(), true));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Microphone access is required. Enable it in Settings > App Permissions.'),
          ),
        );
      }
    }
  }

  void _stopListening() {
    _speechToText.stop();
    _animationController.stop();
    _animationController.reset();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _speechToText.isListening;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: isListening
          ? 'Recording. Tap to stop.'
          : 'Voice input button. Tap to dictate your idea.',
      button: true,
      liveRegion: isListening,
      child: InkWell(
        onTap: widget.isEnabled ? _toggleListening : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: isListening
                ? (disableAnimations
                    ? Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      )
                    : ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ))
                : Icon(
                    Icons.mic,
                    color: widget.isEnabled
                        ? AppColors.electricViolet
                        : AppColors.textTertiary,
                  ),
          ),
        ),
      ),
    );
  }
}
