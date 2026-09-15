import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/mclash_node_filter.dart';
import 'package:mclash/mf/mclash_pseudo_nodes.dart';
import 'package:mclash/app/utils/platform_utils.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_define.dart';
import 'package:mclash/screens/widgets/sheet.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProxyScreenProxiesNodeWidgetController {
  void Function()? onTesting;

  Future<void> Function()? delayTestFun;
  int Function()? delayTestingFun;

  /// 本轮测速的节点总数（与 [delayTestingFun] 的「剩余数」配对，
  /// 用来给 UI 算真实进度：已完成 = 总数 − 剩余）。
  int Function()? delayTestTotalFun;
  ProxyScreenProxiesNodeWidgetController({required this.onTesting});
  Future<void> delayTest() async {
    if (delayTestFun != null) {
      return delayTestFun!.call();
    }
  }

  int delayTesting() {
    if (delayTestingFun != null) {
      return delayTestingFun!.call();
    }
    return 0;
  }

  /// 本轮测速总数；未在测速时为 0。
  int delayTestTotal() {
    if (delayTestTotalFun != null) {
      return delayTestTotalFun!.call();
    }
    return 0;
  }
}

class ProxyScreenProxiesNodeWidget extends StatefulWidget {
  const ProxyScreenProxiesNodeWidget({
    super.key,
    required this.nodes,
    this.filter = "",
    required this.controller,
  });
  final List<ClashProxiesNode> nodes;

  /// 节点筛选词。为空 = 不筛选（保持 Clash Mi 原有行为：只列分组）。
  /// 非空 = 直接平铺列出命中的**节点**，并且「测速」只测这些节点。
  final String filter;
  final ProxyScreenProxiesNodeWidgetController? controller;
  @override
  State<ProxyScreenProxiesNodeWidget> createState() =>
      _ProxyScreenProxiesNodeWidget();
}

class _ProxyScreenProxiesNodeWidget
    extends State<ProxyScreenProxiesNodeWidget> {
  late List<ClashProxiesNode> _nodes;
  final Set<String> _nodesTesting = {};

  /// 本轮测速的总节点数（用于算真实进度；非测速时为 0）。
  int _nodesTestTotal = 0;

  @override
  void initState() {
    widget.controller?.delayTestFun = () async {
      return delayTest();
    };
    widget.controller?.delayTestingFun = () {
      return _nodesTesting.length;
    };
    widget.controller?.delayTestTotalFun = () {
      return _nodesTestTotal;
    };
    _nodes = widget.nodes.toList();
    super.initState();
  }

  /// 节点是否命中筛选词。
  ///
  /// 匹配范围刻意放大到「名字 + 类型」：用户想找日本节点时会输 `jp`
  /// 或 `日本`，也可能想按协议筛（`vless`、`ss`）。全部大小写不敏感。
  /// 另外伪节点（📢 官网/⏰ 到期 等）永不参与筛选 —— 它们不是节点。
  /// 复用 MclashNodeFilter 的纯逻辑（该文件有独立单元测试覆盖边界条件）。
  bool _matches(ClashProxiesNode n) => MclashNodeFilter.matches(_entry(n), widget.filter);

  NodeFilterEntry _entry(ClashProxiesNode n) => NodeFilterEntry(
        name: n.name,
        type: n.type,
        isGroup: ClashProtocolType.GroupToList().contains(n.type),
        hidden: n.hidden,
      );

  bool get _filtering => widget.filter.trim().isNotEmpty;

  /// 当前应展示的节点集合。
  ///
  ///   · 不筛选 → 保持 Clash Mi 原样：只列**分组**（点进去选节点）；
  ///   · 筛选时 → 直接平铺列出命中的**真实节点**。
  ///     这样「输 jp → 看到 JP-日本-直连 → 点闪电只测这几个」是一条连贯动作，
  ///     而不是筛完只剩空分组、用户不知道筛掉了什么。
  List<ClashProxiesNode> _visibleNodes() {
    if (!_filtering) {
      return _nodes;
    }
    final out = MclashNodeFilter.select<ClashProxiesNode>(
      _nodes,
      widget.filter,
      describe: _entry,
    );
    // 与分组视图保持一致：开启「按延迟排序」时把已知延迟排前面
    if (SettingManager.getConfig().ui.delayTestSort) {
      out.sort((a, b) {
        if (a.delay == null && b.delay == null) return 0;
        if (a.delay == null) return 1;
        if (b.delay == null) return -1;
        return a.delay!.compareTo(b.delay!);
      });
    }
    return out;
  }

  /// 本轮测速的目标节点名（跳过分组与伪节点）。
  List<String> _delayTestTargets() {
    final out = <String>[];
    for (final n in _nodes) {
      if (ClashProtocolType.GroupToList().contains(n.type)) {
        continue;
      }
      if (!canDelayTest(n.type)) {
        continue;
      }
      if (MclashPseudoNodes.isPseudo(n.name)) {
        continue;
      }
      if (_filtering && !_matches(n)) {
        continue; // 筛选测速：只测当前筛选结果
      }
      out.add(n.name);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;
    double iconSize = 20;
    var widgets = [];
    // 遍历 _visibleNodes()：
    //   不筛选 → 与原来完全一致（只列分组，行为不变，避免动到保留功能）；
    //   筛选时 → 平铺列出命中的真实节点。
    for (var node in _visibleNodes()) {
      if (!_filtering) {
        // 未筛选：保持原逻辑，只列分组
        if (!ClashProtocolType.GroupToList().contains(node.type)) {
          continue;
        }
        if (node.hidden) {
          continue;
        }
      }
      String subtitle = "";
      Color? color;
      if (node.delay != null && node.delay! > 0) {
        subtitle = "(${node.delay} ms)";
        if (node.delay! < 800) {
          color = ThemeDefine.kColorGreenBright;
        } else if (node.delay! < 1500) {
          color = Colors.black;
        } else {
          color = Colors.red;
        }
      }

      widgets.add(
        ListTile(
          title: node.icon.isNotEmpty
              ? Row(
                  children: [
                    FastCachedImage(
                      url: node.icon,
                      width: 16,
                      height: 16,
                      cacheWidth: 64,
                      cacheHeight: 64,
                      loadingBuilder: (context, loadingProgress) {
                        return SizedBox.shrink();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(width: 5),
                    Text(
                      node.name,
                      style: TextStyle(
                        fontFamily: Platform.isWindows ? 'Emoji' : null,
                      ),
                    ),
                  ],
                )
              : Text(
                  node.name,
                  style: TextStyle(
                    fontFamily: Platform.isWindows ? 'Emoji' : null,
                  ),
                ),
          subtitle: !_nodesTesting.contains(node.name)
              ? (node.delay == null
                    ? Text(node.type)
                    : Row(
                        children: [
                          Text(node.type),
                          SizedBox(width: 5),
                          Tooltip(
                            message: node.delayErr ?? "",
                            child: InkWell(
                              onTap: !canDelayTest(node.type)
                                  ? null
                                  : () async {
                                      delayTest(nodeName: node.name);
                                      if (node.delayErr != null &&
                                          node.delayErr!.isNotEmpty) {
                                        try {
                                          await Clipboard.setData(
                                            ClipboardData(text: node.delayErr!),
                                          );
                                        } catch (e) {}
                                      }
                                    },
                              child: Text(
                                subtitle,
                                style: TextStyle(color: color),
                              ),
                            ),
                          ),
                        ],
                      ))
              : Row(
                  children: [
                    Text(node.type),
                    SizedBox(width: 5),
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: RepaintBoundary(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
          trailing: SizedBox(
            width: windowSize.width * 0.4,
            child: Row(
              children: [
                SizedBox(
                  width: windowSize.width * 0.4 - iconSize,
                  child: Text(
                    node.now,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Platform.isWindows ? 'Emoji' : null,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_right, size: iconSize),
              ],
            ),
          ),
          minVerticalPadding: 10,
          onTap: () {
            showNodeSelect(node);
          },
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Scrollbar(
          child: ListView.separated(
            itemBuilder: (_, index) {
              return widgets[index];
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 1, thickness: 0.3);
            },
            itemCount: widgets.length,
          ),
        ),
      ),
    );
  }

  void showNodeSelect(ClashProxiesNode selectNode) {
    Size windowSize = MediaQuery.of(context).size;
    var widgets = [];

    List<ClashProxiesNode> newNodes = [];
    for (var p in selectNode.all) {
      for (var n in _nodes) {
        if (n.name == p) {
          newNodes.add(n);
          break;
        }
      }
    }

    if (SettingManager.getConfig().ui.delayTestSort) {
      newNodes.sort((a, b) {
        if (a.delay == null || b.delay == null) {
          return 1;
        }

        return a.delay! - b.delay!;
      });
    }
    for (int i = 0; i < newNodes.length; ++i) {
      final node = newNodes[i];
      String subtitle = "";
      Color? color;
      if (node.delay != null && node.delay! > 0) {
        subtitle = "(${node.delay} ms)";
        if (node.delay! < 800) {
          color = ThemeDefine.kColorGreenBright;
        } else if (node.delay! < 1500) {
          color = Colors.black;
        } else {
          color = Colors.red;
        }
      } else if (node.delayErr != null && node.delayErr!.isNotEmpty) {
        subtitle = "(${node.delayErr})";
        color = Colors.red;
      }

      widgets.add(
        ListTile(
          title: node.icon.isNotEmpty
              ? Row(
                  children: [
                    Text("${i + 1}"),
                    SizedBox(width: 5),
                    FastCachedImage(
                      url: node.icon,
                      width: 16,
                      height: 16,
                      cacheWidth: 16,
                      cacheHeight: 16,
                      loadingBuilder: (context, loadingProgress) {
                        return SizedBox.shrink();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox.shrink();
                      },
                    ),
                    SizedBox(width: 5),
                    Text(
                      node.name,
                      style: TextStyle(
                        fontFamily: Platform.isWindows ? 'Emoji' : null,
                      ),
                    ),
                  ],
                )
              : Text(
                  "${i + 1} ${node.name}",
                  style: TextStyle(
                    fontFamily: Platform.isWindows ? 'Emoji' : null,
                  ),
                ),
          subtitle: subtitle.isEmpty
              ? Text(node.type)
              : Row(
                  children: [
                    Text(node.type),
                    SizedBox(width: 5),
                    Tooltip(
                      message: node.delayErr ?? "",
                      child: InkWell(
                        onTap: !canDelayTest(node.type)
                            ? null
                            : () async {
                                Navigator.of(context).pop();
                                delayTest(nodeName: node.name);
                                if (node.delayErr != null &&
                                    node.delayErr!.isNotEmpty) {
                                  try {
                                    await Clipboard.setData(
                                      ClipboardData(text: node.delayErr!),
                                    );
                                  } catch (e) {}
                                }
                              },
                        child: Text(subtitle, style: TextStyle(color: color)),
                      ),
                    ),
                  ],
                ),
          selected: selectNode.now == node.name,
          selectedColor: ThemeDefine.kColorBlue,
          onTap: () async {
            var error = await ClashHttpApi.setProxiesNode(
              selectNode.name,
              node.name,
            );
            if (!mounted) {
              return;
            }
            if (error != null) {
              DialogUtils.showAlertDialog(context, error.message);
              return;
            }

            selectNode.now = node.name;
            selectNode.delay = getGroupDelay(selectNode.now);
            for (var group in _nodes) {
              if (ClashProtocolType.GroupToList().contains(group.type)) {
                group.delay = getGroupDelay(group.now);
              }
            }
            Navigator.of(context).pop();
            setState(() {});
          },
        ),
      );
    }
    showSheet(
      context: context,
      body: SizedBox(
        height: windowSize.height - 200,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Scrollbar(
            child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return widgets[index];
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 1, thickness: 0.3);
              },
              itemCount: widgets.length,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> delayTest({String nodeName = ""}) async {
    final setting = SettingManager.getConfig();
    _nodesTesting.clear();

    if (nodeName.isNotEmpty) {
      // 单节点测速（长按某一行触发）：只测它自己
      _nodesTesting.add(nodeName);
      _nodesTestTotal = 1;
    } else {
      // 批量测速：目标 = 全部可测真实节点；**有筛选词时只测筛选结果**，
      // 这就是「筛选测速」——先筛出想测的那几个，再点闪电只测它们。
      for (final n in _delayTestTargets()) {
        _nodesTesting.add(n);
      }
      _nodesTestTotal = _nodesTesting.length;
    }
    if (_nodesTestTotal == 0) {
      // 没东西可测（例如筛选没命中任何节点）时不要留一个虚假的进行中状态
      widget.controller?.onTesting?.call();
      return;
    }
    widget.controller?.onTesting?.call();

    var nextIndex = 0;
    Future<void> testNext() async {
      while (nextIndex < _nodes.length) {
        final node = _nodes[nextIndex++];
        // 只测本轮目标集合里的节点（单节点测速 / 筛选测速都靠这个收口）
        if (!_nodesTesting.contains(node.name) && nodeName.isEmpty) {
          continue;
        }
        if (nodeName.isNotEmpty && node.name != nodeName) {
          continue;
        }

        if (canDelayTest(node.type) && !MclashPseudoNodes.isPseudo(node.name)) {
          final result = await ClashHttpApi.getDelay(
            node.name,
            url: setting.delayTestUrl,
            timeout: Duration(milliseconds: setting.delayTestTimeout),
          );

          node.delay = result.data;
          node.delayErr = result.error?.message;

          for (var group in _nodes) {
            if (ClashProtocolType.GroupToList().contains(group.type)) {
              if (group.now == node.name) {
                group.delay = node.delay;
                break;
              }
            }
          }
        }

        _nodesTesting.remove(node.name);
        if (_nodesTesting.isEmpty) {
          _nodesTestTotal = 0;
        }
        if (!mounted) {
          return;
        }

        widget.controller?.onTesting?.call();
      }
    }

    int maxConcurrentTests = PlatformUtils.isPC() ? 10 : 5;
    await Future.wait([
      for (var i = 0; i < maxConcurrentTests; ++i) testNext(),
    ]);
    for (var group in _nodes) {
      if (ClashProtocolType.GroupToList().contains(group.type)) {
        group.delay = getGroupDelay(group.now);
      }
    }
    widget.controller?.onTesting?.call();
  }

  int? getGroupDelay(String groupName) {
    for (var group in _nodes) {
      if (group.name == groupName) {
        if (group.delay != null) {
          return group.delay;
        }
        if (ClashProtocolType.GroupToList().contains(group.type)) {
          return getGroupDelay(group.now);
        }
        return group.delay;
      }
    }
    return null;
  }

  bool canDelayTest(String nodeType) {
    return ClashProtocolType.direct.name == nodeType ||
        !ClashProtocolType.toList().contains(nodeType);
  }
}
