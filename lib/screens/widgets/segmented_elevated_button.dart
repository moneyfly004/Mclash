import 'package:flutter/material.dart';
import 'package:mclash/screens/theme_define.dart';

class SegemntedElevatedButtonItem {
  const SegemntedElevatedButtonItem({required this.value, required this.text});

  final int value;
  final String text;
}

class SegmentedElevatedButton extends StatefulWidget {
  const SegmentedElevatedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.padding,
    this.background,
    this.buttonStyle,
    this.onPressed,
  });

  final List<SegemntedElevatedButtonItem> segments;

  final int selected;
  final EdgeInsetsGeometry? padding;
  final Color? background;
  final ButtonStyle? buttonStyle;
  final Function(int value)? onPressed;

  @override
  State<SegmentedElevatedButton> createState() => _SegmentedElevatedButton();
}

class _SegmentedElevatedButton extends State<SegmentedElevatedButton> {
  static const double _height = 34;
  static const double _radius = 18;

  late int _selected = widget.selected;

  @override
  void didUpdateWidget(SegmentedElevatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _selected = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: widget.background ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius + 3),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < widget.segments.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(_radius),
                onTap: () {
                  if (_selected == i) {
                    return;
                  }
                  setState(() => _selected = i);
                  widget.onPressed?.call(widget.segments[i].value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: _height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selected == i
                        ? ThemeDefine.kColorBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(_radius),
                  ),
                  child: Text(
                    widget.segments[i].text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selected == i
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _selected == i
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
