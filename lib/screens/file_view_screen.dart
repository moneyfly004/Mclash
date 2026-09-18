import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

typedef EditingValueChangeBuilder = Widget Function(CodeLineEditingValue value);

class FileViewScreen extends StatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "/");
  }

  final String title;
  final String content;
  final Function(BuildContext context, String content)? onSave;

  const FileViewScreen({
    super.key,
    required this.title,
    required this.content,
    this.onSave,
  });

  @override
  State<FileViewScreen> createState() => _FileViewScreenState();
}

class _FileViewScreenState extends State<FileViewScreen> {
  late CodeLineEditingController _controller;

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = CodeLineEditingController.fromText(widget.content);

    _focusNode.onKeyEvent = ((_, event) {
      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      final key = event.logicalKey;
      if (!keys.contains(key)) {
        return KeyEventResult.ignored;
      }
      if (key == LogicalKeyboardKey.arrowUp) {
        _controller.moveCursor(AxisDirection.up);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _controller.moveCursor(AxisDirection.down);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _controller.selection.endIndex;
        _controller.moveCursor(AxisDirection.left);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _controller.moveCursor(AxisDirection.right);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }

  @override
  void dispose() {

    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 「复制」按钮：**可编辑**时沿用编辑器语义（选区 / 当前行），
  /// **只读查看**（日志、运行配置这类）时：有选区就复制选区，没选区就复制**全文**。
  ///
  /// 为什么必须改（用户实测）：`re_editor` 的 `copy()` 在选区折叠时**只复制
  /// 光标所在的那一行**。用户打开「我的 → 应用日志」直接点复制，拿到的就是
  /// 第一行 —— 也就是 `日志文件：C:\Users\...\app.log` 这个**路径**，
  /// 于是反馈「你复制的是日志的路径不是日志内容」。日志是给人贴出来看的，
  /// 只读页面的一键复制就该是全文。
  Future<void> _copy() async {
    final ctx = context;
    final readOnly = widget.onSave == null;
    final collapsed = _controller.selection.isCollapsed;
    final selected = _controller.selectedText;
    if (readOnly && collapsed) {
      // 只读页面 + 没有选区 → 复制全文（用户点「复制」要的就是整份日志）
      final all = _controller.text;
      await Clipboard.setData(ClipboardData(text: all));
      if (!ctx.mounted) {
        return;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text("已复制全部内容（${all.length} 字符；选中后可只复制选区）"),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    // 编辑器 / 有选区 → 沿用编辑器原语义（选区，或折叠时的当前行）
    await _controller.copy();
    if (!ctx.mounted) {
      return;
    }
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          collapsed
              ? "已复制当前行（选中多行可复制选区）"
              : "已复制选中内容（${selected.length} 字符）",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tcontext = Translations.of(context);
    Size windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 50,
                      height: 30,
                      child: Icon(Icons.arrow_back_ios_outlined, size: 26),
                    ),
                  ),
                  SizedBox(
                    width: windowSize.width - 50 * 3,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  if (widget.onSave != null) ...[
                    InkWell(
                      onTap: () async {
                        widget.onSave!(context, _controller.text);
                      },
                      child: Tooltip(
                        message: tcontext.meta.save,
                        child: const SizedBox(
                          width: 50,
                          height: 30,
                          child: Icon(Icons.done, size: 26),
                        ),
                      ),
                    ),
                  ],
                  if (widget.onSave == null) ...[const SizedBox(width: 50)],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _controller.selectAll();
                    },
                    child: Tooltip(
                      message: tcontext.meta.selectAll,
                      child: const SizedBox(
                        width: 50,
                        height: 30,
                        child: Icon(Icons.select_all, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _copy,
                    child: Tooltip(
                      message: widget.onSave == null
                          ? "复制全部内容（选中时只复制选区）"
                          : tcontext.meta.copy,
                      child: const SizedBox(
                        width: 50,
                        height: 30,
                        child: Icon(Icons.copy, size: 26),
                      ),
                    ),
                  ),
                  if (widget.onSave != null) ...[
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        _controller.paste();
                      },
                      child: Tooltip(
                        message: tcontext.meta.paste,
                        child: const SizedBox(
                          width: 50,
                          height: 30,
                          child: Icon(Icons.paste, size: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        _controller.cut();
                      },
                      child: Tooltip(
                        message: tcontext.meta.cut,
                        child: const SizedBox(
                          width: 50,
                          height: 30,
                          child: Icon(Icons.cut, size: 26),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                  child: CodeEditor(
                    readOnly: widget.onSave == null,
                    showCursorWhenReadOnly: widget.onSave == null,
                    focusNode: _focusNode,
                    scrollbarBuilder: (context, child, details) {
                      return Scrollbar(
                        controller: details.controller,
                        thickness: 8,
                        radius: const Radius.circular(2),
                        interactive: true,
                        child: child,
                      );
                    },
                    indicatorBuilder:
                        (
                          context,
                          editingController,
                          chunkController,
                          notifier,
                        ) {
                          return Row(
                            children: [
                              DefaultCodeLineNumber(
                                controller: editingController,
                                notifier: notifier,
                              ),
                              DefaultCodeChunkIndicator(
                                width: 20,
                                controller: chunkController,
                                notifier: notifier,
                              ),
                            ],
                          );
                        },
                    shortcutsActivatorsBuilder:
                        DefaultCodeShortcutsActivatorsBuilder(),
                    controller: _controller,

                    style: CodeEditorStyle(
                      fontSize: 14,
                      codeTheme: CodeHighlightTheme(
                        languages: {
                          'yaml': CodeHighlightThemeMode(mode: langYaml),
                          'json': CodeHighlightThemeMode(mode: langJson),
                        },
                        theme: atomOneLightTheme,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
