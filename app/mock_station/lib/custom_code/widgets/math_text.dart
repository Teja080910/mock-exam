import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

final RegExp _texPattern = RegExp(
  r'\\\((.+?)\\\)|\\\[(.+?)\\\]|\$\$(.+?)\$\$',
  dotAll: true,
);

final RegExp _htmlTagPattern = RegExp(r'<[^>]*>');

final RegExp _texCommandPattern = RegExp(
  r'\\(frac|dfrac|tfrac|sqrt|left|right|text|mathrm|mathbf|div|times|cdot|quad|qquad|pm|mp|leq|geq|neq|approx|sum|prod|int|lim|log|ln|sin|cos|tan|theta|alpha|beta|gamma|pi|infty|overline|underline|vec|bar|hat|binom|displaystyle|begin|end)\b',
);

String _cleanTex(String value) {
  return value
      .replaceAll(_htmlTagPattern, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _escapeAttribute(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

String injectMathTags(String input) {
  final replaced = input.replaceAllMapped(_texPattern, (match) {
    final inline = match.group(1);
    final displayBlock = match.group(2);
    final displayDollar = match.group(3);
    final tex = _cleanTex(inline ?? displayBlock ?? displayDollar ?? '');
    final display = inline == null;
    return '<math-tex tex="${_escapeAttribute(tex)}" display="$display"></math-tex>';
  });
  if (replaced.contains('math-tex')) {
    return replaced;
  }
  if (_texCommandPattern.hasMatch(replaced)) {
    return '<math-tex tex="${_escapeAttribute(_cleanTex(replaced))}" display="true"></math-tex>';
  }
  return replaced;
}

List<InlineSpan> _buildMathSpans(String text, TextStyle? style) {
  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final match in _texPattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    final inline = match.group(1);
    final tex = _cleanTex(inline ?? match.group(2) ?? match.group(3) ?? '');
    final display = inline == null;
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          tex,
          mathStyle: display ? MathStyle.display : MathStyle.text,
          textStyle: style,
          onErrorFallback: (error) => Text(tex, style: style),
        ),
      ),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  return spans;
}

List<InlineSpan> mathInlineSpans(String text, TextStyle? style) {
  if (_texPattern.hasMatch(text)) {
    return _buildMathSpans(text, style);
  }
  if (_texCommandPattern.hasMatch(text)) {
    final tex = _cleanTex(text);
    return [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          tex,
          mathStyle: MathStyle.text,
          textStyle: style,
          onErrorFallback: (error) => Text(text, style: style),
        ),
      ),
    ];
  }
  return [TextSpan(text: text)];
}

class MathTexElement extends StyledElement {
  MathTexElement({
    required super.node,
    required super.style,
    required super.children,
    required this.tex,
    required this.display,
    super.name,
    super.elementId,
    super.elementClasses,
  });

  final String tex;
  final bool display;
}

class MathTexExtension extends HtmlExtension {
  const MathTexExtension();

  @override
  Set<String> get supportedTags => {'math-tex'};

  @override
  StyledElement prepare(ExtensionContext context, List<StyledElement> children) {
    return MathTexElement(
      node: context.node,
      style: Style(),
      children: children,
      tex: context.attributes['tex'] ?? '',
      display: context.attributes['display'] == 'true',
    );
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final styledElement = context.styledElement;
    final tex = styledElement is MathTexElement ? styledElement.tex : '';
    final display = styledElement is MathTexElement && styledElement.display;
    final textStyle = styledElement?.style.generateTextStyle();
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Math.tex(
        tex,
        mathStyle: display ? MathStyle.display : MathStyle.text,
        textStyle: textStyle,
        onErrorFallback: (error) => Text(tex, style: textStyle),
      ),
    );
  }
}

class MathHtml extends StatelessWidget {
  const MathHtml({
    super.key,
    required this.data,
    this.onLinkTap,
    this.onAnchorTap,
    this.style = const {},
    this.shrinkWrap = false,
    this.extensions = const [],
  });

  final String data;
  final OnTap? onLinkTap;
  final OnTap? onAnchorTap;
  final Map<String, Style> style;
  final bool shrinkWrap;
  final List<HtmlExtension> extensions;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: injectMathTags(data),
      onLinkTap: onLinkTap,
      onAnchorTap: onAnchorTap,
      style: style,
      shrinkWrap: shrinkWrap,
      extensions: [const MathTexExtension(), ...extensions],
    );
  }
}

class MathText extends StatelessWidget {
  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    if (!_texPattern.hasMatch(text) && !_texCommandPattern.hasMatch(text)) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );
    }
    return Text.rich(
      TextSpan(style: style, children: mathInlineSpans(text, style)),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
