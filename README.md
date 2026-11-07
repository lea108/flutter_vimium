
Provides vim inspired navigation to your flutter apps. Inspired by
browser extensions such as vimium and vimium-c.

The package is independent of UI packages and provide default (yellow) hint
style, but you can easily provide your own using your UI package of
choice. The example app shows how to do this for material_ui using purple Badge widgets.

![Short demo clip](docs/demo_clip_short_1x.webp)

Also see [longer demo clip](docs/demo_clip_1x.webp) showing of also dialogs and scrolling down with `d`.

## Shortcuts

* `f`: Alphabet hint navigation
* `h`: Scroll left
* `j`: Scroll down
* `k`: Scroll up
* `l`: Scroll left
* `u`: Scroll up full page
* `d`: Scroll down full page
* `i`: Enter insert mode where all input is ignored until you press `Escape`


## Alphabet hint navigation

1. Press `f` to enter alphabet hint navigation
2. Vimium will resolve focusable widgets and place a 1+ letter hint overlay above each widget
3. User types the letters on any hint overlay to activate it
4. Upon activation Vimium will set focus to the target FocusNode and then invoke ActivateIntent on it, causing
   buttons to be clicked etc.

![Clip of alphabet hint navigation]()


## Getting started

1. Make sure your works using the keyboard. This step is mostly to test that things that are button-like can receive focus and that dialogs correctly trap focus traversal.
2. Install the `flutter_vimium` package
3. Add a builder for your MaterialApp or similar, depending on the UI kit you use.

    ```dart
    MaterialApp(
        builder: (context, child) => Vimium(child: child),
        home: HomeScreen(),
    )
    ```

    It should be added quite far up in the widget tree, but still be able to insert a FocusNode and a Stack to overlay widgets.

    If you instead wrap the material_ui Scaffold of each view, there can be issues
    with Vimium not working in dialogs and other overlays like dropdowns.

4. Start your app and press the `f` key to enter Alphabet hint mode. For scroll shortcuts to work, the primaryFocus need to be within a scroll view. You may need to press `tab` or use `f` to move focus first before you can scroll.

## Configuration:

You can optionally customize the look and behavior of the Vimium experience using these parameters:

* `shortcuts` - provide a custom shortcuts map.
* `hintOverlayBuilder` - customize the hint overlays
* `offset` - customize hint overlay offset
* `hintCharacters` - customize the alphabet. Preferable use letters on the home row of the active keyboard layout.
* `onHintActivate` - provide a custom handler for when a hint is activated that can block or permit the default activation.
* `autofocus` - optionally disable autofocus on the Focus node of Vimium
