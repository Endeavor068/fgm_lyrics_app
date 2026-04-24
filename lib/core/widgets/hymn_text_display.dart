import 'package:fgm_lyrics_app/app/settings/typography_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders a hymn text string that may contain either plain text or HTML
/// produced by a WYSIWYG editor.
///
/// Font size and family are driven by [fontSizeProvider] and
/// [fontFamilyProvider] so user preferences apply automatically.
///
/// When HTML tags are detected the widget uses [Html] so that rich formatting
/// (bold, italic, underline, colour, etc.) is faithfully reproduced.
/// Plain text strings fall back to a regular [Text] widget.
class HymnTextDisplay extends ConsumerWidget {
  const HymnTextDisplay({
    super.key,
    required this.text,
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.normal,
    this.lineHeight = 1.6,
    this.color,
  });

  final String text;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final double lineHeight;

  /// Overrides the text colour. Falls back to [TextTheme.bodyLarge] colour.
  final Color? color;

  static final _htmlTagPattern = RegExp(r'<[a-zA-Z][^>]*>');

  /// Returns true when [value] contains at least one HTML tag.
  static bool isHtml(String value) => _htmlTagPattern.hasMatch(value);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    final resolvedColor = color ?? Theme.of(context).textTheme.bodyLarge?.color;

    final plainStyle = fontFamily.textStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: lineHeight,
      color: resolvedColor,
    );

    if (!isHtml(text)) {
      return Text(text, textAlign: textAlign, style: plainStyle);
    }

    return Html(
      data: text,
      shrinkWrap: true,
      style: {
        'body': Style.fromTextStyle(plainStyle).copyWith(
          textAlign: textAlign,
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
        ),
        'p': Style(padding: HtmlPaddings.zero, margin: Margins.only(bottom: 6)),
        'li': Style(
          padding: HtmlPaddings.zero,
          margin: Margins.only(bottom: 4),
        ),
      },
    );
  }
}
