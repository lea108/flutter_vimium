## unreleased

* feat: VimiumController that can observe hint overlay active status and close the hint overlay
* fix: throw an exception on duplicate characters in hintCharacters
* fix: old hints could show when hint generation aborted due to zero targets
* fix: dispose() FocusNode created by Vimium widget
* fix: there is no 'i' in QWERTY home row
* fix!: VimumAction renamed to VimiumAction (typo)
* change!: make Vimium class final
* docs: fix documented scroll direction of `l` key
* docs: Update README.md and package description

BREAKING CHANGE: VimumAction renamed to VimiumAction (typo)

BREAKING CHANGE: Vimium class is now final

## 0.0.4

* fix: avoid hints ending up partially outside of the screen, fixes#1
* remove: drop unused initialRepeatDelay and repeatDelay parameters for Vimium class
* docs: fix API docs for Vimium.shortcuts
* docs: fix API docs text layout
* docs: exclude README animated clips from published dart package to reduce size

## 0.0.3

* docs: Fix link to raw clip at github
* docs: Improve API docs coverage

## 0.0.2

* docs: Use full URLs for images/links in README.md
* docs: Extend package description

## 0.0.1

* Initial release
