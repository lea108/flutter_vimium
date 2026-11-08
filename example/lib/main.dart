import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_vimium/flutter_vimium.dart';
import 'package:super_keyboard_layout/super_keyboard_layout.dart';

Future<void> main() async {
  final hintCharacters = await _getHomeRow();
  runApp(ExampleApp(hintCharacters));
}

class ExampleApp extends StatefulWidget {
  final String hintCharacters;
  const ExampleApp(this.hintCharacters, {super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final customHints = ValueNotifier<bool>(false);
  final controller = VimiumController();

  @override
  void initState() {
    super.initState();
    customHints.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // Place Vimium widget here using MaterialApp.builder to make hint
    // navigation work also with overlays such as dialogs etc.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Vimium(
        hintCharacters: widget.hintCharacters,
        // Provide a custom hint overlay builder if you want to customize the look
        // and feel of the hint overlays.
        hintOverlayBuilder: customHints.value ? _customHintBuilder : null,
        // If you want to handle when user activated a widget using a hint yourself
        // you can provide onHintActivate:
        onHintActivate: (target) async {
          debugPrint('Hint activated ${target.debugLabel ?? ''}');
          // Let the default activation run
          return .ignored;
        },
        controller: controller,
        child: child ?? SizedBox.shrink(),
      ),
      home: HomeScreen(customHints, controller),
    );
  }

  Widget _customHintBuilder(
    BuildContext context,
    String hint,
    int nMatchedChars,
  ) {
    final matchedText = hint.substring(0, nMatchedChars);
    final remainingText = hint.substring(nMatchedChars, hint.length);
    final remainingStyle = TextTheme.of(context).bodyLarge!
        .copyWith(fontWeight: .bold);
    final matchedStyle = remainingStyle.copyWith(
      color: Colors.grey[700]!.withAlpha(155),
    );
    return Badge(
      backgroundColor: Colors.purple[100],
      textColor: Colors.black,
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: matchedText, style: matchedStyle),
            TextSpan(text: remainingText, style: remainingStyle),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ValueNotifier<bool> customHints;
  final VimiumController controller;

  const HomeScreen(this.customHints, this.controller, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int dropdownValue = 1;
  int n = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              onPressed: () => showSnackbar(context, 'Hello'),
              child: Text('Hello'),
            ),
            ElevatedButton(
              onPressed: () => showSnackbar(context, 'World'),
              child: Text('World'),
            ),
            ElevatedButton(
              onPressed: () => showAbout(context),
              child: Text('Show dialog'),
            ),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            ValueListenableBuilder(
              valueListenable: widget.customHints,
              builder: (context, value, child) => ListTile(
                leading: Checkbox(
                  value: widget.customHints.value,
                  onChanged: _onCheckboxChange,
                ),
                title: Text('Use custom hints builder'),
              ),
            ),
            ListTile(
              title: Text('Select a number'),
              trailing: DropdownButton<int>(
                value: dropdownValue,
                items: [
                  ...[
                    1,
                    2,
                    3,
                  ].map((i) => DropdownMenuItem(value: i, child: Text('$i'))),
                ],
                onChanged: _onDropdownChange,
              ),
            ),
            ListTile(
              title: Text('Number of buttons'),
              subtitle: Slider(
                min: 0,
                max: 10,
                divisions: 10,
                label: '$n',
                value: n.toDouble(),
                onChanged: _onSliderChange,
              ),
            ),
            ...List<Widget>.generate(
              n,
              (i) => ElevatedButton(
                onPressed: () => showSnackbar(context, 'Button ${i + 1}'),
                child: Text('${i + 1}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), showCloseIcon: true));
    widget.controller.closeHintOverlay();
  }

  void showAbout(BuildContext context) {
    showAboutDialog(context: context, applicationName: 'Vimium Example');
    widget.controller.closeHintOverlay();
  }

  void _onSliderChange(double value) {
    setState(() {
      n = value.round();
    });
    widget.controller.closeHintOverlay();
  }

  void _onDropdownChange(int? value) {
    if (value == null) return;
    setState(() {
      dropdownValue = value;
    });
    widget.controller.closeHintOverlay();
  }

  void _onCheckboxChange(bool? value) {
    if (value == null) return;
    widget.customHints.value = value;
    widget.controller.closeHintOverlay();
  }
}

Future<String> _getHomeRow() async {
  const fallback = 'asdfghjkl';
  final layoutManager = await KeyboardLayoutManager.instance();
  if (!layoutManager.supported) {
    return fallback;
  }
  final layout = layoutManager.currentLayout;

  final physicalHomeRow = [
    PhysicalKeyboardKey.keyA,
    PhysicalKeyboardKey.keyS,
    PhysicalKeyboardKey.keyD,
    PhysicalKeyboardKey.keyF,
    PhysicalKeyboardKey.keyG,
    PhysicalKeyboardKey.keyH,
    PhysicalKeyboardKey.keyJ,
    PhysicalKeyboardKey.keyK,
    PhysicalKeyboardKey.keyL,
    PhysicalKeyboardKey.semicolon,
  ];

  final logicalHomeRow = physicalHomeRow.map(
    (pk) => layout.getLogicalKeyForPhysicalKey(pk),
  );

  final homeRow = logicalHomeRow
      .map((lk) => lk?.keyLabel)
      .nonNulls
      .where((s) => s.toLowerCase() != s.toUpperCase())
      .join()
      .toLowerCase();
  return homeRow.length >= 5 ? homeRow : fallback;
}
