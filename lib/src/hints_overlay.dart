import 'package:flutter/widgets.dart';
import 'package:flutter_vimium/src/hint_overlay_data.dart';
import 'package:flutter_vimium/src/utils.dart';

class const HintsOverlay({
  required final List<HintOverlayData> hints,
  required final String typedText,
  required final Offset offset,
  required final Widget Function(
    BuildContext context,
    String hint,
    int nMatchedChars,
  )?
  overlayBuilder,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .passthrough,
      children: [
        child,
        ...hints.map((hint) {
          final nMatchedChars = getNMatchedChars(hint.hint, typedText);
          final hide = nMatchedChars < typedText.length;
          if (hide) {
            return SizedBox.shrink();
          }
          return Positioned(
            left: hint.rect.left + offset.dx,
            top: hint.rect.top + offset.dy,
            child: overlayBuilder != null
                ? overlayBuilder!(context, hint.hint.toUpperCase(), nMatchedChars)
                : _buildDefaultOverlay(context, hint, nMatchedChars),
          );
        }),
      ],
    );
  }

  Container _buildDefaultOverlay(
    BuildContext context,
    HintOverlayData hint,
    int nMatchedChars,
  ) {
    const borderColor = Color.fromARGB(255, 212, 191, 0);
    const bgColor = Color.fromARGB(255, 255, 230, 0);
    const bgColor2 = Color.fromARGB(255, 238, 214, 0);
    const textColor = Color.fromARGB(255, 0, 0, 0);
    const matchTextColor = Color.fromARGB(155, 100, 100, 100);
    const baseTextStyle = TextStyle(
      color: textColor,
      fontSize: 12,
      fontWeight: .w700,
      fontStyle: .normal,
      decoration: .none,
    );
    const matchTextStyle = TextStyle(
      color: matchTextColor,
      fontSize: 12,
      fontWeight: .w700,
      fontStyle: .normal,
      decoration: .none,
    );
    final String matchText = hint.hint
        .substring(0, nMatchedChars)
        .toUpperCase();
    final String endText = hint.hint
        .substring(nMatchedChars, hint.hint.length)
        .toUpperCase();

    return Container(
      padding: EdgeInsets.fromLTRB(4, 1, 4, 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor2],
          begin: .topCenter,
          end: .bottomCenter,
        ),
        border: BoxBorder.all(color: borderColor),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 1,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color.fromARGB(15, 0, 0, 0),
            blurRadius: 3,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color.fromARGB(15, 0, 0, 0),
            blurRadius: 8,
            spreadRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: matchText, style: matchTextStyle),
            TextSpan(text: endText, style: baseTextStyle),
          ],
        ),
      ),
    );
  }
}
