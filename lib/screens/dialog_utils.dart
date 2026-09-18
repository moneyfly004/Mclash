// ignore_for_file: empty_catches

import 'dart:io';

import 'package:mclash/app/utils/app_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/widgets/dropdown.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libclash_vpn_service/vpn_service.dart';
import 'package:tuple/tuple.dart';

class DialogUtilsResult<T> {
  DialogUtilsResult(this.data);
  T? data;
}

class DialogUtils {
  static Future<void> Function(BuildContext context, String text)? faqCallback;

  static Future<void> showAlertDialog(
    BuildContext context,
    String text, {
    bool showCopy = false,
    bool showFAQ = false,
    bool withVersion = false,
  }) async {
    if (!context.mounted) {
      return;
    }
    double width = 60;
    if (showCopy) {
      width = 20;
    }
    if (withVersion) {
      text =
          "${AppUtils.getBuildinVersion()} ${Platform.operatingSystem}\n\n$text";
    }

    const int kMaxLength = 1024;
    if (text.length > kMaxLength) {
      text = text.substring(
        0,
        kMaxLength,
      );
    }

    if (showFAQ && Platform.isAndroid) {
      String version = await FlutterVpnService.getSystemVersion();
      int? v = int.tryParse(version);
      if (v != null && v == 27) {

        showFAQ = false;
      }
      if (!context.mounted) {
        return;
      }
    }

    final tcontext = Translations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: "showAlertDialog"),
      builder: (context) {
        return SimpleDialog(
          title: Text(
            tcontext.meta.tips,
            style: const TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: ThemeConfig.kFontSizeListSubItem,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text(tcontext.meta.ok),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
                if (showCopy) ...[
                  SizedBox(width: width),
                  ElevatedButton(
                    child: Text(tcontext.meta.copy),
                    onPressed: () async {
                      try {
                        await Clipboard.setData(ClipboardData(text: text));
                      } catch (e) {}
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            if (showFAQ) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ElevatedButton(
                  child: Text(tcontext.meta.faq),
                  onPressed: () async {
                    await faqCallback?.call(context, text);
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String text, {
    bool showCopy = false,
    bool withVersion = false,
  }) async {
    if (!context.mounted) {
      return null;
    }
    if (withVersion) {
      text =
          "${AppUtils.getBuildinVersion()} ${Platform.operatingSystem}\n\n$text";
    }
    final tcontext = Translations.of(context);
    return await showDialog<bool>(
      context: context,
      routeSettings: const RouteSettings(name: "showConfirmDialog"),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                text,
                maxLines: 20,
                style: const TextStyle(
                  fontSize: ThemeConfig.kFontSizeListSubItem,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text(tcontext.meta.cancel),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context, false);
                  },
                ),
                const SizedBox(width: 60),
                ElevatedButton(
                  child: Text(tcontext.meta.ok),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (showCopy) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ElevatedButton(
                  child: Text(tcontext.meta.copy),
                  onPressed: () async {
                    try {
                      await Clipboard.setData(ClipboardData(text: text));
                    } catch (e) {}
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  static Future<String?> showTextInputDialog(
    BuildContext context,
    String title,
    String text,
    String? labelText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool Function(String) callback, {
    bool obscureText = false,
  }) async {
    if (!context.mounted) {
      return null;
    }
    final tcontext = Translations.of(context);
    final textController = TextEditingController();
    textController.value = textController.value.copyWith(text: text);
    return showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: "showTextInputDialog"),
      builder: (context) {
        return SimpleDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                controller: textController,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: labelText),
                textAlign: TextAlign.end,
                obscureText: obscureText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text(tcontext.meta.cancel),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context, null);
                  },
                ),
                const SizedBox(width: 60),
                ElevatedButton(
                  child: Text(tcontext.meta.ok),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    if (callback(textController.text)) {
                      Navigator.pop(context, textController.text);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<Tuple2<int, int>?> showTextIntRangeInputDialog(
    BuildContext context,
    String title,
    Tuple2<int, int>? labelText,
    bool Function(Tuple2<int, int>) callback,
  ) async {
    if (!context.mounted) {
      return null;
    }
    final tcontext = Translations.of(context);
    final textControllerL = TextEditingController();
    final textControllerR = TextEditingController();
    textControllerL.value = textControllerL.value.copyWith(
      text: labelText != null ? labelText.item1.toString() : "",
    );
    textControllerR.value = textControllerR.value.copyWith(
      text: labelText != null ? labelText.item2.toString() : "",
    );
    return showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: "showTextIntRangeInputDialog"),
      builder: (context) {
        return SimpleDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      controller: textControllerL,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                const Text(
                  "-",
                  style: TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      controller: textControllerR,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text(tcontext.meta.cancel),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context, null);
                  },
                ),
                const SizedBox(width: 60),
                ElevatedButton(
                  child: Text(tcontext.meta.ok),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    if (textControllerL.text.isNotEmpty &&
                        textControllerR.text.isNotEmpty &&
                        callback(
                          Tuple2(
                            int.parse(textControllerL.text),
                            int.parse(textControllerR.text),
                          ),
                        )) {
                      Navigator.pop(
                        context,
                        Tuple2(
                          int.parse(textControllerL.text),
                          int.parse(textControllerR.text),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<int?> showIntInputDialog(
    BuildContext context,
    String title,
    int? value,
    int? min,
    int? max,
  ) async {
    String mm = (min != null && max != null) ? "$min-$max" : "";
    String? text = await DialogUtils.showTextInputDialog(
      context,
      title,
      value != null ? value.toString() : "",
      mm,
      TextInputType.number,
      [FilteringTextInputFormatter.digitsOnly],
      (text) {
        text = text.trim();
        int? p = int.tryParse(text);
        if (p == null) {
          return false;
        }
        if (min != null) {
          if (p < min) {
            return false;
          }
        }
        if (max != null) {
          if (p > max) {
            return false;
          }
        }

        return true;
      },
    );
    if (text == null) {
      return null;
    }
    return int.tryParse(text);
  }

  static Future<Tuple2<int, int>?> showIntRangeInputDialog(
    BuildContext context,
    String title,
    Tuple2<int, int>? value,
    int min,
    int max,
  ) async {
    return await DialogUtils.showTextIntRangeInputDialog(
      context,
      title,
      value,
      (tuple2) {
        if (tuple2.item1 < min ||
            tuple2.item2 > max ||
            tuple2.item1 > tuple2.item2) {
          return false;
        }
        return true;
      },
    );
  }

  static Future<DialogUtilsResult<Duration>?> showTimeIntervalPickerDialog(
    BuildContext context,
    Duration? duration, {
    bool showDays = true,
    bool showHours = true,
    bool showMinutes = true,
    bool showSeconds = true,
    bool showMilliSeconds = false,
    bool showDisable = true,
  }) async {
    if (!context.mounted) {
      return null;
    }
    final tcontext = Translations.of(context);
    final textController = TextEditingController();
    String days = "d(${tcontext.meta.days})";
    String hours = "h(${tcontext.meta.hours})";
    String minutes = "m(${tcontext.meta.minutes})";
    String seconds = "s(${tcontext.meta.seconds})";
    String milliseconds = "ms(${tcontext.meta.milliseconds})";
    List<String> data = [];

    if (showDays) {
      data.add(days);
    }
    if (showHours) {
      data.add(hours);
    }
    if (showMinutes) {
      data.add(minutes);
    }
    if (showSeconds) {
      data.add(seconds);
    }
    if (showMilliSeconds) {
      data.add(milliseconds);
    }
    if (showDisable) {
      data.add(tcontext.meta.disable);
    }
    String selected = data.first;
    if (duration != null) {
      if (duration.inDays > 0) {
        selected = days;
        textController.value = textController.value.copyWith(
          text: duration.inDays.toString(),
        );
      } else if (duration.inHours > 0) {
        selected = hours;
        textController.value = textController.value.copyWith(
          text: duration.inHours.toString(),
        );
      } else if (duration.inMinutes > 0) {
        selected = minutes;
        textController.value = textController.value.copyWith(
          text: duration.inMinutes.toString(),
        );
      } else if (duration.inSeconds > 0) {
        selected = seconds;
        textController.value = textController.value.copyWith(
          text: duration.inSeconds.toString(),
        );
      } else if (duration.inMilliseconds > 0) {
        selected = milliseconds;
        textController.value = textController.value.copyWith(
          text: duration.inMilliseconds.toString(),
        );
      }
    } else {
      selected = tcontext.meta.disable;
      textController.value = textController.value.copyWith(text: "");
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: "showTimeIntervalPickerDialog"),
      builder: (context) {
        return SimpleDialog(
          title: const Text(
            "",
            style: TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
          ),
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.done,
                        controller: textController,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButtonEx(
                      menuWidth: 200,
                      value: selected,
                      items: _buildDropButtonList(data),
                      onChanged: (String? sel) {
                        selected = sel ?? data.first;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text(tcontext.meta.cancel),
                      onPressed: () {
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context, null);
                      },
                    ),
                    const SizedBox(width: 60),
                    ElevatedButton(
                      child: Text(tcontext.meta.ok),
                      onPressed: () {
                        if (!context.mounted) {
                          return;
                        }
                        int? value = int.tryParse(textController.text);
                        if (value == null) {
                          Navigator.pop(context, null);
                          return;
                        }
                        Duration? duration;
                        if (selected == days) {
                          duration = Duration(days: value);
                        } else if (selected == hours) {
                          duration = Duration(hours: value);
                        } else if (selected == minutes) {
                          duration = Duration(minutes: value);
                        } else if (selected == seconds) {
                          duration = Duration(seconds: value);
                        } else if (selected == milliseconds) {
                          duration = Duration(milliseconds: value);
                        } else if (selected == tcontext.meta.disable) {}

                        Navigator.pop(context, DialogUtilsResult(duration));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<DialogUtilsResult<String>?> showStringPickerDialog(
    BuildContext context,
    String title,
    List<String> strings,
    String? selected,
  ) async {
    if (!context.mounted) {
      return null;
    }
    final tcontext = Translations.of(context);
    final textController = TextEditingController();

    textController.value = textController.value.copyWith(text: selected ?? "");

    return showDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: "showStringPickerDialog"),
      builder: (context) {
        return SimpleDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
          ),
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButtonEx(
                      menuWidth: 200,
                      value: selected,
                      items: _buildDropButtonList(strings),
                      onChanged: (String? sel) {
                        selected = sel ?? strings.first;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text(tcontext.meta.cancel),
                      onPressed: () {
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context, null);
                      },
                    ),
                    const SizedBox(width: 60),
                    ElevatedButton(
                      child: Text(tcontext.meta.ok),
                      onPressed: () {
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.pop(context, DialogUtilsResult(selected));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static List<DropdownMenuItem<String>> _buildDropButtonList(
    List<String> data,
  ) {
    return data.map((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }

  /// 加载弹窗的句柄：**记住推它的那个 navigator**，由调用方负责关闭。
  ///
  /// 为什么需要句柄（真实事故）：主页每个 tab 都套了一层 `Navigator`
  /// （见 `MainTabShell`），而 `showDialog` 默认推在**根** navigator 上。
  /// 调用方若用 `Navigator.of(context).pop()` 去关，拿到的是 **tab 内层**那个
  /// navigator —— 它栈里通常是空的，`canPop()` 为 false，于是 pop 被跳过，
  /// 而 loading 弹窗既不能点遮罩关闭、又不能返回：用户卡在「正在检查更新…」
  /// 转圈界面，只能重启 App。
  ///
  /// 现在：句柄内部用**弹窗自己的 context** 关闭（`mounted` 判断 + 幂等），
  /// 无论成功、失败、超时还是异常都能保证关掉。
  static LoadingDialogHandle showLoadingDialogHandle(
    BuildContext context, {
    String? text,
  }) {
    final handle = LoadingDialogHandle();
    if (!context.mounted) {
      return handle;
    }
    final tcontext = Translations.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        routeSettings: const RouteSettings(name: "showLoadingDialog"),
        barrierDismissible: false,
        fullscreenDialog: true,
        builder: (dialogContext) {
          handle._dialogContext = dialogContext;
          // 调用方可能在弹窗**还没建好**时就请求关闭（例如检查瞬间完成、
          // 直接返回缓存结果）：这里补一次延迟关闭，否则弹窗会永远留在最上层。
          handle._onBuilt();
          return PopScope(
            // 允许返回/Esc 退出：手动触发的操作**必须能退出来**。
            // 万一代码路径出问题（或网络卡住），用户至少能自己关掉这个弹窗，
            // 而不是只能重启 App。
            canPop: true,
            child: SimpleDialog(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const RepaintBoundary(child: CircularProgressIndicator()),
                    Padding(
                      padding: const EdgeInsets.only(top: 26.0),
                      child: Text(text ?? tcontext.meta.loading),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ).whenComplete(() => handle._closed = true),
    );
    return handle;
  }

  /// 兼容老调用点：只显示、由调用方自行关闭（新代码请用
  /// [showLoadingDialogHandle]，用句柄关闭更可靠）。
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String? text,
  }) async {
    showLoadingDialogHandle(context, text: text);
  }

  static Future<void> showQRContentDialog(
    BuildContext context,
    String text,
  ) async {
    if (!context.mounted) {
      return;
    }
    final tcontext = Translations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: "showQRContentDialog"),
      builder: (context) {
        return SimpleDialog(
          title: Text(
            tcontext.meta.qrcodeScanResult,
            style: const TextStyle(fontSize: ThemeConfig.kFontSizeListSubItem),
          ),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: ThemeConfig.kFontSizeListSubItem,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  child: Text(tcontext.meta.add),
                  onPressed: () {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// [DialogUtils.showLoadingDialogHandle] 的关闭句柄。
///
/// 关弹窗这件事看着简单，但有两个坑都踩过：
///   1. 关错 navigator：调用方在 tab 内层 navigator 里 `pop()`，
///      而弹窗挂在根 navigator 上 → 关不掉（用户卡在转圈界面只能重启）；
///   2. 关得太早：`showDialog` 是**下一帧**才构建弹窗的，
///      如果检查瞬间完成、在构建前就调 `close()`，那时还没有弹窗的 context，
///      直接 pop 会落空 → 弹窗留下来。
/// 所以这里：用**弹窗自己的 context** 关，并且允许「先请求、后补关」。
class LoadingDialogHandle {
  LoadingDialogHandle();

  BuildContext? _dialogContext;
  bool _closeRequested = false;
  bool _closed = false;

  /// 弹窗是否已经关掉（被用户返回关掉也算）。
  bool get isClosed => _closed;

  /// 关闭弹窗。**幂等**，且弹窗还没建好时也安全（会记住请求，建好后立刻补关）。
  void close() {
    if (_closeRequested) {
      return;
    }
    _closeRequested = true;
    _tryPopNow();
    _scheduleRetry();
  }

  /// 弹窗刚构建完成时调用（内部使用）。
  void _onBuilt() => _scheduleRetry();

  /// 下一帧再试一次：覆盖「先请求关闭、后建好弹窗」的时序。
  void _scheduleRetry() {
    if (_closed) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_closeRequested && !_closed) {
        _tryPopNow();
      }
    });
  }

  void _tryPopNow() {
    if (_closed) {
      return;
    }
    final dialogContext = _dialogContext;
    if (dialogContext == null || !dialogContext.mounted) {
      return;
    }
    // 先置位再关：避免用户手快连点两次时把下面的页面也关掉
    _closed = true;
    // 用弹窗自己的 context 取 navigator 与它所属的 route：
    //   * 用调用方的 context 会拿到 tab 内层 navigator（关错/关不掉）；
    //   * 单纯 `Navigator.pop()` 只会弹**栈顶**：如果这期间又压了别的弹窗
    //     （例如「已是最新版本」提示），pop 会把别人弹掉、loading 反而留在屏幕上
    //     —— 这个 bug 我在自测里踩到过。
    // 所以这里精确移除**这个**弹窗 route。
    final navigator = Navigator.of(dialogContext);
    final route = ModalRoute.of(dialogContext);
    if (route != null) {
      navigator.removeRoute(route);
    } else {
      navigator.pop();
    }
  }
}
