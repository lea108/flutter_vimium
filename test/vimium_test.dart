import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vimium/flutter_vimium.dart';
import 'package:flutter_vimium/src/utils.dart';

void main() {
  testWidgets('Vimium - hint overlay', (tester) async {
    final characters = 'vim';
    final controller = VimiumController();
    int lastClicked = -1;

    await tester.pumpWidget(
      WidgetsApp(
        color: Color.fromARGB(255, 125, 0, 125),
        builder: (context, child) => Vimium(
          hintCharacters: characters,
          controller: controller,
          child: child ?? SizedBox.shrink(),
        ),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        ),
        home: Column(
          mainAxisSize: .min,
          children: [
            for (final i in [1, 2, 3])
              TestButton(
                onPressed: () => lastClicked = i,
                child: Text('Button $i'),
              ),
          ],
        ),
      ),
    );
    expect(find.text('Button 1'), findsOneWidget);
    expect(controller.isHintOverlayActive, false);

    await tester.sendKeyEvent(.keyF);
    await tester.pumpAndSettle();
    expect(controller.isHintOverlayActive, true);
    final expectedHints = generateHintList(3, characters);
    expect(find.text('Button 1'), findsOneWidget);
    expect(find.text(expectedHints.first.toUpperCase()), findsOneWidget);
    expect(expectedHints.first, equals('v'));
    expect(lastClicked, equals(-1));
    await tester.sendKeyEvent(.keyV);
    await tester.pumpAndSettle();
    expect(lastClicked, equals(1));
    expect(controller.isHintOverlayActive, false);
    expect(find.text(expectedHints.first), findsNothing);
  });
}

class TestButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const TestButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Semantics(button: true, child: child),
      ),
    );
  }
}
