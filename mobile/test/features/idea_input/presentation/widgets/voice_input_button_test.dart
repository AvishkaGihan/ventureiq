import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:ventureiq_app/features/idea_input/presentation/widgets/voice_input_button.dart';

class MockSpeechToText extends Mock implements SpeechToText {}
class FakeSpeechListenOptions extends Fake implements SpeechListenOptions {}

void main() {
  late MockSpeechToText mockSpeechToText;

  setUpAll(() {
    registerFallbackValue(FakeSpeechListenOptions());
  });

  setUp(() {
    mockSpeechToText = MockSpeechToText();
    // Default mocks
    when(() => mockSpeechToText.isListening).thenReturn(false);
    when(() => mockSpeechToText.initialize(
          onError: any(named: 'onError'),
          onStatus: any(named: 'onStatus'),
        )).thenAnswer((_) async => true);
    when(() => mockSpeechToText.stop()).thenAnswer((_) async {});
    when(() => mockSpeechToText.listen(
          onResult: any(named: 'onResult'),
        )).thenAnswer((_) async {});
  });

  Widget createWidget({
    bool isEnabled = true,
    required void Function(String) onTranscription,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: VoiceInputButton(
          isEnabled: isEnabled,
          onTranscription: onTranscription,
          speechToText: mockSpeechToText,
        ),
      ),
    );
  }

  testWidgets('renders idle mic icon and semantics', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget(onTranscription: (_) {}));

    final semantics = find.bySemanticsLabel('Voice input button. Tap to dictate your idea.');
    expect(semantics, findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });

  testWidgets('tap transitions to listening state when available', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget(onTranscription: (_) {}));

    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();

    verify(() => mockSpeechToText.initialize(
          onError: any(named: 'onError'),
          onStatus: any(named: 'onStatus'),
        )).called(1);
    verify(() => mockSpeechToText.listen(onResult: any(named: 'onResult'))).called(1);

    when(() => mockSpeechToText.isListening).thenReturn(true);
    // Force a rebuild to reflect listening state
    await tester.pumpAndSettle();

    final semantics = find.bySemanticsLabel('Recording. Tap to stop.');
    expect(semantics, findsOneWidget);
  });

  testWidgets('tap during listening stops transcription', (WidgetTester tester) async {
    // Start listening initially
    when(() => mockSpeechToText.isListening).thenReturn(true);

    await tester.pumpWidget(createWidget(onTranscription: (_) {}));

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    verify(() => mockSpeechToText.stop()).called(1);
  });

  testWidgets('permission denied shows SnackBar guidance', (WidgetTester tester) async {
    // Initialize returns false (permission denied)
    when(() => mockSpeechToText.initialize(
          onError: any(named: 'onError'),
          onStatus: any(named: 'onStatus'),
        )).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidget(onTranscription: (_) {}));

    await tester.tap(find.byIcon(Icons.mic));
    await tester.pumpAndSettle();

    expect(find.text('Microphone access is required. Enable it in Settings > App Permissions.'), findsOneWidget);
  });

  testWidgets('transcribed text is passed via callback', (WidgetTester tester) async {
    String transcribed = '';
    await tester.pumpWidget(createWidget(onTranscription: (text) => transcribed = text));

    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();

    // Capture the listen callback to simulate recognition result
    final invocation = verify(() => mockSpeechToText.listen(onResult: captureAny(named: 'onResult'))).captured.first;
    final onResultCallback = invocation as void Function(SpeechRecognitionResult);

    // Provide a mocked result
    onResultCallback(SpeechRecognitionResult(
      [SpeechRecognitionWords('test idea', 1.0)],
      false,
    ));

    expect(transcribed, 'test idea');
  });

  testWidgets('Reduce motion disables pulsing animation', (WidgetTester tester) async {
    when(() => mockSpeechToText.isListening).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          body: VoiceInputButton(
            isEnabled: true,
            onTranscription: (_) {},
            speechToText: mockSpeechToText,
          ),
        ),
      ),
    ));

    expect(find.byIcon(Icons.mic), findsNothing);
    // Should show static red circle/icon instead of AnimatedContainer pulse
    final staticIndicator = find.byType(Container).evaluate().where((element) {
      final widget = element.widget as Container;
      if (widget.decoration is BoxDecoration) {
        return (widget.decoration as BoxDecoration).color == const Color(0xFFEF4444);
      }
      return false;
    });
    expect(staticIndicator.isNotEmpty, isTrue);
  });

  testWidgets('speech recognition error shows SnackBar guidance', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget(onTranscription: (_) {}));

    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();

    final invocation = verify(() => mockSpeechToText.initialize(
          onError: captureAny(named: 'onError'),
          onStatus: any(named: 'onStatus'),
        )).captured.first;
    final onErrorCallback = invocation as void Function(SpeechRecognitionError);

    // Simulate an error
    onErrorCallback(SpeechRecognitionError('error_network', true));
    await tester.pumpAndSettle();

    expect(find.text('Network error. Please check your connection and try again.'), findsOneWidget);
  });
}
