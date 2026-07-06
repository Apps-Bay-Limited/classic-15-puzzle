import 'dart:async';

import 'package:flutter/widgets.dart';

/// Flutter widget that automatically resizes text to fit perfectly within its bounds.
///
/// All size constraints as well as maxLines are taken into account. If the text
/// overflows anyway, you should check if the parent widget actually constraints
/// the size of this widget.
class AutoSizeText extends StatefulWidget {
  /// Creates a [AutoSizeText] widget.
  ///
  /// If the [style] argument is null, the text will use the style from the
  /// closest enclosing [DefaultTextStyle].
  const AutoSizeText(
    this.data,
    this.text, {
    super.key,
    this.textKey,
    this.style,
    this.strutStyle,
    this.minFontSize = 12,
    this.maxFontSize = double.infinity,
    this.stepGranularity = 1,
    this.presetFontSizes,
    this.group,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.wrapWords = true,
    this.overflow,
    this.overflowReplacement,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
  });

  /// Sets the key for the resulting [Text] widget.
  ///
  /// This allows you to find the actual `Text` widget built by `AutoSizeText`.
  final Key? textKey;

  /// The text to calculate font size.
  final String data;

  /// The text to display.
  final String text;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's 'inherit' property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  // The default font size if none is specified.
  static const double _defaultFontSize = 14.0;

  /// The strut style to use. Strut style defines the strut, which sets minimum
  /// vertical layout metrics.
  ///
  /// Omitting or providing null will disable strut.
  ///
  /// Omitting or providing null for any properties of [StrutStyle] will result in
  /// default values being used. It is highly recommended to at least specify a
  /// font size.
  ///
  /// See [StrutStyle] for details.
  final StrutStyle? strutStyle;

  /// The minimum text size constraint to be used when auto-sizing text.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double minFontSize;

  /// The maximum text size constraint to be used when auto-sizing text.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double maxFontSize;

  /// The step size in which the font size is being adapted to constraints.
  ///
  /// The Text scales uniformly in a range between [minFontSize] and
  /// [maxFontSize].
  /// Each increment occurs as per the step size set in stepGranularity.
  ///
  /// Most of the time you don't want a stepGranularity below 1.0.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double stepGranularity;

  /// Predefines all the possible font sizes.
  ///
  /// **Important:** PresetFontSizes have to be in descending order.
  final List<double>? presetFontSizes;

  /// Synchronizes the size of multiple [AutoSizeText]s.
  ///
  /// If you want multiple [AutoSizeText]s to have the same text size, give all
  /// of them the same [AutoSizeGroup] instance. All of them will have the
  /// size of the smallest [AutoSizeText]
  final AutoSizeGroup? group;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  final bool? softWrap;

  /// Whether words which don't fit in one line should be wrapped.
  ///
  /// If false, the fontSize is lowered as far as possible until all words fit
  /// into a single line.
  final bool wrapWords;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// If the text is overflowing and does not fit its bounds, this widget is
  /// displayed instead.
  final Widget? overflowReplacement;

  /// The text scaler.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  ///
  /// This property also affects [minFontSize], [maxFontSize] and [presetFontSizes].
  ///
  /// If null, will use the [MediaQueryData.textScaler] obtained from the ambient
  /// [MediaQuery].
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be resized according
  /// to the specified bounds and if necessary truncated according to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  /// An alternative semantics label for this text.
  ///
  /// If present, the semantics of this widget will contain this value instead
  /// of the actual text. This will overwrite any of the semantics labels applied
  /// directly to the [TextSpan]s.
  ///
  /// This is useful for replacing abbreviations or shorthands with the full
  /// text value:
  ///
  /// ```dart
  /// Text(r'$$', semanticsLabel: 'Double dollars')
  /// ```
  final String? semanticsLabel;

  @override
  AutoSizeTextState createState() => AutoSizeTextState();
}

class AutoSizeTextState extends State<AutoSizeText> {
  @override
  void initState() {
    super.initState();
    widget.group?._register(this);
  }

  @override
  void didUpdateWidget(AutoSizeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.group != widget.group) {
      oldWidget.group?._remove(this);
      widget.group?._register(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final defaultTextStyle = DefaultTextStyle.of(context);

      var style = widget.style;
      if (style == null || style.inherit) {
        style = defaultTextStyle.style.merge(style);
      }
      if (style.fontSize == null) {
        style = style.copyWith(fontSize: AutoSizeText._defaultFontSize);
      }

      final maxLines = widget.maxLines ?? defaultTextStyle.maxLines;

      _sanityCheck(style, maxLines);

      final result = _calculateFontSize(constraints, style, maxLines);
      final fontSize = result[0] as double;
      final textFits = result[1] as bool;

      widget.group?._updateFontSize(this, fontSize);
      final displayFontSize = widget.group?._fontSize ?? fontSize;

      final text = _buildText(displayFontSize, style, maxLines);

      if (!textFits && widget.overflowReplacement != null) {
        return widget.overflowReplacement!;
      } else {
        return text;
      }
    });
  }

  void _sanityCheck(TextStyle style, int? maxLines) {
    assert(maxLines == null || maxLines > 0,
        'MaxLines has to be greater than or equal to 1.');
    assert(widget.key == null || widget.key != widget.textKey,
        'Key and textKey cannot be the same.');

    if (widget.presetFontSizes != null) {
      assert(widget.presetFontSizes!.isNotEmpty,
          'PresetFontSizes has to be nonempty.');
    }
  }

  List _calculateFontSize(
      BoxConstraints constraints, TextStyle style, int? maxLines) {
    final span = TextSpan(
      style: style,
      text: widget.data,
    );

    final userScale =
        widget.textScaler?.scale(1.0) ?? MediaQuery.maybeTextScalerOf(context)?.scale(1.0) ?? 1.0;

    int left;
    int right;

    final presetFontSizes = widget.presetFontSizes?.reversed.toList();
    if (presetFontSizes != null) {
      left = 0;
      right = presetFontSizes.length - 1;

      var lastValueFits = false;
      while (left <= right) {
        final mid = (left + (right - left) / 2).toInt();
        final scale = presetFontSizes[mid] * userScale / style.fontSize!;
        if (_checkTextFits(span, scale, maxLines, constraints)) {
          left = mid + 1;
          lastValueFits = true;
        } else {
          right = mid - 1;
        }
      }

      if (!lastValueFits) {
        right += 1;
      }

      final fontSize = presetFontSizes[right.clamp(0, presetFontSizes.length - 1)] * userScale;
      return [fontSize, lastValueFits];
    } else {
      // Binary search for font size
      var min = widget.minFontSize;
      var max = widget.maxFontSize;
      if (max == double.infinity) {
        max = style.fontSize!;
      }

      var lastValueFits = true;
      while (min <= max) {
        final mid = (min + (max - min) / 2);
        final scale = mid * userScale / style.fontSize!;
        if (_checkTextFits(span, scale, maxLines, constraints)) {
          min = mid + widget.stepGranularity;
          lastValueFits = true;
        } else {
          max = mid - widget.stepGranularity;
          lastValueFits = false;
        }
      }
      return [max * userScale, lastValueFits];
    }
  }

  bool _checkTextFits(
      TextSpan text, double scale, int? maxLines, BoxConstraints constraints) {
    if (!widget.wrapWords) {
      final words = text.toPlainText().split(RegExp(r'\s+'));

      final wordWrapTp = TextPainter(
        text: TextSpan(
          style: text.style,
          text: words.join('\n'),
        ),
        textAlign: widget.textAlign ?? TextAlign.left,
        textDirection: widget.textDirection ?? TextDirection.ltr,
        textScaler: TextScaler.linear(scale),
        maxLines: words.length,
        locale: widget.locale,
        strutStyle: widget.strutStyle,
      );

      wordWrapTp.layout(maxWidth: constraints.maxWidth);

      if (wordWrapTp.didExceedMaxLines ||
          wordWrapTp.width > constraints.maxWidth) {
        return false;
      }
    }

    final tp = TextPainter(
      text: text,
      textAlign: widget.textAlign ?? TextAlign.left,
      textDirection: widget.textDirection ?? TextDirection.ltr,
      textScaler: TextScaler.linear(scale),
      maxLines: maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
    );

    tp.layout(maxWidth: constraints.maxWidth);

    return !(tp.didExceedMaxLines ||
        tp.height > constraints.maxHeight ||
        tp.width > constraints.maxWidth);
  }

  Widget _buildText(double fontSize, TextStyle style, int? maxLines) {
    return Text(
      widget.text,
      key: widget.textKey,
      style: style.copyWith(fontSize: fontSize),
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: TextScaler.noScaling,
      maxLines: maxLines,
      semanticsLabel: widget.semanticsLabel,
    );
  }

  void _notifySync() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.group?._remove(this);
    super.dispose();
  }
}

/// Controller to synchronize the fontSize of multiple AutoSizeTexts.
class AutoSizeGroup {
  final _listeners = <AutoSizeTextState, double>{};
  var _widgetsNotified = false;
  double _fontSize = double.infinity;

  void _register(AutoSizeTextState text) {
    _listeners[text] = double.infinity;
  }

  void _updateFontSize(AutoSizeTextState text, double maxFontSize) {
    final oldFontSize = _fontSize;
    if (maxFontSize <= _fontSize) {
      _fontSize = maxFontSize;
      _listeners[text] = maxFontSize;
    } else if (_listeners[text] == _fontSize) {
      _listeners[text] = maxFontSize;
      _fontSize = double.infinity;
      for (final size in _listeners.values) {
        if (size < _fontSize) _fontSize = size;
      }
    } else {
      _listeners[text] = maxFontSize;
    }

    if (oldFontSize != _fontSize) {
      _widgetsNotified = false;
      scheduleMicrotask(_notifyListeners);
    }
  }

  void _notifyListeners() {
    if (_widgetsNotified) {
      return;
    } else {
      _widgetsNotified = true;
    }

    for (final textState in _listeners.keys) {
      if (textState.mounted) {
        textState._notifySync();
      }
    }
  }

  void _remove(AutoSizeTextState text) {
    _updateFontSize(text, double.infinity);
    _listeners.remove(text);
  }
}
