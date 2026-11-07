import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vimium/src/hint_overlay_data.dart';
import 'package:flutter_vimium/src/hints_overlay.dart';
import 'package:flutter_vimium/src/utils.dart';

/// Return value for [Vimium.onHintActivate].
enum HintActivateResult {
  /// Blocks default handling of hint activation.
  handled,

  /// Allow default handling of hint activation.
  ignored,
}

/// Shortcut actions for [Vimium.shortcuts].
enum VimumAction {
  activateHintOverlay,
  scrollLeft,
  scrollRight,
  scrollUp,
  scrollDown,
  scrollUpPage,
  scrollDownPage,

  /// Leave insert mode or abort active hint overlay
  escape,

  /// Enter insert mode where all shortcuts are ignored except for those
  /// with escape action.
  insertMode,
}

/// Provide Vimium-inspired keyboard navigation for Flutter apps.
///
/// When user taps F, it obtains a list of all FocusNodes that
///  * can be traversed
///  * are visible on screen (at least partially)
///  * has a context
///
/// Using these focus nodes it builds an overlay with hint labels that
/// the user has to type using the keyboard to activate it.
///
/// When a hint gets activated, focus will be moved to it and
/// the ActivateIntent is emitted.
///
/// Configurations:
///  * [shortcuts] redefine keyboard shortcuts
///  * [hintCharacters] define the letters that may be used in alphabet hints.
///  * [hintOverlayBuilder] provide a custom builder for the hint overlays.
///  * [hintOffset] offset from FocusNode.rect top left corner for overlays.
///  * [autofocus] allow disabling autofocus on Focus node created.
///  * [onHintActivate] provides ability to intercept/handle activated hints yourself.
///
/// Place this widget fairly high up in the widget tree so that it encapsulates overlays
/// that your UI package creates while also still being within the app. For material_ui
/// this is can be solved by using the builder parameter of MaterialApp.
class const Vimium({
  /// Active set of shortcuts for Vimium.
  ///
  /// If you only want to enable hint navigation you can use
  /// [Vimium.hintNavigationShortcuts].
  final Map<SingleActivator, VimumAction> shortcuts = const {
    SingleActivator(.keyF): .activateHintOverlay,
    SingleActivator(.keyH): .scrollLeft,
    SingleActivator(.keyJ): .scrollDown,
    SingleActivator(.keyK): .scrollUp,
    SingleActivator(.keyL): .scrollRight,
    SingleActivator(.keyD): .scrollDownPage,
    SingleActivator(.keyU): .scrollUpPage,
    SingleActivator(.escape): .escape,
    SingleActivator(.keyI): .insertMode,
  },

  /// A string with all the characters to use in hint overlays.
  ///
  /// Typically this would be the home row of the active keyboard layout or
  /// you may provide a app setting for users to customize this.
  final String hintCharacters = 'asdfghijkl',

  /// Builder of hint label widget. The label will be offset by [offset] from
  /// (0, 0) of the focusNode.
  ///
  ///  * `hint` is the text to display on the overlay.
  ///  * `nMatchedChars` provides the number of characters from the beginning of `hint`
  ///    that has matched. Can be used to style the matched part differently to the
  ///    remaining of the hint text.
  final Widget Function(BuildContext context, String hint, int nMatchedChars)?
  hintOverlayBuilder,

  /// Define the offset from top left corner of FocusNode.rect for label placement
  final Offset hintOffset = const Offset(-8.0, -8.0),

  /// If provided, this method is called when a hint is activated. It can return
  ///  * [HintActivateResult.handled] => The default activation is skipped
  ///  * [HintActivateResult.ignored] => The default activation will be performed
  /// If this method is not provided, the default activation is performed.
  final Future<HintActivateResult> Function(FocusNode target)? onHintActivate,

  /// Sets autofocus property of Focus widget created by [Vimium]
  /// to read keyboard input.
  final bool autofocus = true,

  /// The rest of your app or screen.
  required final Widget child,
  super.key,
}) extends StatefulWidget {
  @override
  State<Vimium> createState() => _VimiumState();

  /// Simplified set of shortcuts that only includes shortcuts
  /// for hint navigation
  static Map<SingleActivator, VimumAction> hintNavigationShortcuts = const {
    SingleActivator(.keyF): .activateHintOverlay,
    SingleActivator(.escape): .escape,
  };
}

class _VimiumState extends State<Vimium> {
  late final FocusNode _focusNode = FocusNode(skipTraversal: true);
  late final GlobalKey _focusKey = GlobalKey(debugLabel: 'LinkHintsFocusNode');
  bool _insertMode = false;
  bool _hintOverlayActive = false;
  String _typedText = '';
  List<HintOverlayData> _overlays = [];
  int _maxHintLength = 0;

  @override
  Widget build(BuildContext context) {
    return Focus(
      key: _focusKey,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _onKeyEvent,
      child: HintsOverlay(
        hints: _hintOverlayActive ? _overlays : [],
        typedText: _typedText,
        overlayBuilder: widget.hintOverlayBuilder,
        offset: widget.hintOffset,
        child: widget.child,
      ),
    );
  }

  /// Key handler for when overlay is enabled
  void _onEnableOverlay() {
    if (_hintOverlayActive) {
      return;
    }

    _prepareOverlays();
    setState(() {
      _hintOverlayActive = true;
    });
  }

  void _disableOverlay() {
    setState(() {
      _hintOverlayActive = false;
      _typedText = '';
    });
  }

  /// Keyboard handler for when overlay is visible
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }
    // Always ignore input if a text field is focused
    if (_isEditingText) {
      return .ignored;
    }

    // In insert mode, only escape action is enabled
    if (_insertMode) {
      if (_isEscapeAction(event)) {
        setState(() {
          _insertMode = false;
        });
        return .handled;
      }
      return .ignored;
    }

    // Normal mode (without active hint overlay)
    if (!_hintOverlayActive) {
      for (final shortcut in widget.shortcuts.keys) {
        if (shortcut.accepts(event, HardwareKeyboard.instance)) {
          final action = widget.shortcuts[shortcut]!;
          return _invokeNormalModeAction(action);
        }
      }
      return .ignored;
    }

    // Hint overlay mode
    if (_isEscapeAction(event)) {
      _disableOverlay();
      return .handled;
    }
    if (event.logicalKey == .backspace) {
      if (_typedText.isNotEmpty) {
        setState(() {
          _typedText = _typedText.substring(0, _typedText.length - 1);
        });
      }
      return .handled;
    }

    final char = event.character;
    if (char != null && widget.hintCharacters.contains(char)) {
      setState(() {
        _typedText += char;
      });
      final match = findMatchingOverlay(_overlays, _typedText);
      if (match != null) {
        _disableOverlay();
        unawaited(_activateHint(match));
      } else if (_typedText.length >= _maxHintLength) {
        // Cancel overlay if typed full length and there is no match.
        _disableOverlay();
      }

      return .handled;
    }
    return .ignored;
  }

  bool _isEscapeAction(KeyEvent event) {
    final escapeActivators = widget.shortcuts.entries
        .where((e) => e.value == .escape)
        .map((e) => e.key);
    for (final activator in escapeActivators) {
      if (activator.accepts(event, HardwareKeyboard.instance)) {
        return true;
      }
    }
    return false;
  }

  KeyEventResult _invokeNormalModeAction(VimumAction action) {
    switch (action) {
      case .activateHintOverlay:
        _onEnableOverlay();
        return .handled;
      case .scrollLeft:
        _invokeScroll(ScrollIntent(direction: .left, type: .line));
        return .handled;
      case .scrollRight:
        _invokeScroll(ScrollIntent(direction: .right, type: .line));
        return .handled;
      case .scrollUp:
        _invokeScroll(ScrollIntent(direction: .up, type: .line));
        return .handled;
      case .scrollDown:
        _invokeScroll(ScrollIntent(direction: .down, type: .line));
        return .handled;
      case .scrollDownPage:
        _invokeScroll(ScrollIntent(direction: .down, type: .page));
        return .handled;
      case .scrollUpPage:
        _invokeScroll(ScrollIntent(direction: .up, type: .page));
        return .handled;
      case .escape:
        return .ignored;
      case .insertMode:
        setState(() {
          _insertMode = true;
        });
        return .handled;
    }
  }

  void _invokeScroll(Intent scrollIntent) {
    final invokeContext = primaryFocus?.context ?? context;
    if (invokeContext.mounted) {
      Actions.maybeInvoke(invokeContext, scrollIntent);
    }
  }

  Future<void> _activateHint(HintOverlayData hint) async {
    if (widget.onHintActivate != null) {
      final res = await widget.onHintActivate!(hint.target);
      if (res == .handled) {
        return;
      }
      if (!mounted) return;
    }
    hint.target.requestFocus();
    FocusManager.instance.applyFocusChangesIfNeeded();
    final context = primaryFocus?.context;
    if (context != null && context.mounted) {
      Actions.maybeInvoke(context, ActivateIntent());
    }
  }

  void _prepareOverlays() {
    final screenSize = MediaQuery.sizeOf(context);
    final screenRect = Offset.zero & screenSize;

    final root = primaryFocus?.nearestScope ?? FocusManager.instance.rootScope;
    final targets = root.traversalDescendants.where((node) {
      if (node.context == null) return false;
      if (node == _focusNode) return false;
      if (node is FocusScopeNode) return false;
      final rect = node.rect;
      return !rect.isEmpty && rect.overlaps(screenRect);
    }).toList();

    if (targets.isEmpty) return;
    final hints = generateHintList(targets.length, widget.hintCharacters);

    _overlays = List<HintOverlayData>.generate(targets.length, (i) {
      final target = targets[i];
      return HintOverlayData(rect: target.rect, hint: hints[i], target: target);
    });
    _maxHintLength = _overlays.fold(0, (val, h) => max(val, h.hint.length));
  }

  bool get _isEditingText {
    final context = primaryFocus?.context;
    return context?.findAncestorStateOfType<EditableTextState>() != null;
  }
}
