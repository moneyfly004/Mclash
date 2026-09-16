import 'dart:io';

import 'package:mclash/app/clash/clash_config.dart';
import 'package:mclash/app/clash/clash_http_api.dart';
import 'package:mclash/app/modules/setting_manager.dart';
import 'package:mclash/mf/mclash_flat_nodes.dart';
import 'package:mclash/mf/mclash_mode_selection.dart';
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
    this.kernelOffline = false,
    this.kernelAlive,
    this.flatNodes = false,
  });
  final List<ClashProxiesNode> nodes;

  /// **扁平节点模式**（全局模式用）：不展示策略组，直接列出真实节点让用户选。
  ///
  /// 用户要求：「全局模式我不要看到 global / 组名，只能看到国家节点可以选择」。
  /// 全局模式下所有流量都由内核 GLOBAL 决定，策略组没有意义 —— 列出来只会
  /// 让人以为「选了组里的节点就会生效」。
  final bool flatNodes;

  final bool kernelOffline;

  final Future<bool> Function()? kernelAlive;

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

  bool _matches(ClashProxiesNode n) => MclashNodeFilter.matches(_entry(n), widget.filter);

  NodeFilterEntry _entry(ClashProxiesNode n) => NodeFilterEntry(
        name: n.name,
        type: n.type,
        isGroup: ClashProtocolType.GroupToList().contains(n.type),
        hidden: n.hidden,
      );

  bool get _filtering => widget.filter.trim().isNotEmpty;

  List<ClashProxiesNode> _visibleNodes() {
    if (!_filtering) {
      if (!widget.flatNodes) {
        return _nodes;
      }
      // 扁平模式：只要真实节点，按延迟升序（延迟最低的排最前）
      return flatSelectableNodes(_nodes);
    }
    final out = MclashNodeFilter.select<ClashProxiesNode>(
      _nodes,
      widget.filter,
      describe: _entry,
    );

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
        continue;
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

    for (var node in _visibleNodes()) {
      if (!_filtering) {

        if (widget.flatNodes) {
          // 扁平模式里只列真实节点（策略组不列）
          if (ClashProtocolType.GroupToList().contains(node.type)) {
            continue;
          }
        } else {
          if (!ClashProtocolType.GroupToList().contains(node.type)) {
            continue;
          }
          if (node.hidden) {
            continue;
          }
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
          trailing: widget.flatNodes
              ? SizedBox(
                  width: windowSize.width * 0.4,
                  child: Text(
                    (node.delay != null && node.delay! > 0)
                        ? "${node.delay} ms"
                        : "—",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: (node.delay != null && node.delay! > 0)
                          ? (node.delay! < 800
                                ? ThemeDefine.kColorGreenBright
                                : ThemeDefine.kColorGrey)
                          : ThemeDefine.kColorGrey,
                    ),
                  ),
                )
              : SizedBox(
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
            if (widget.flatNodes) {
              _selectFlatNode(node);
              return;
            }
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

  /// 扁平模式（全局模式）：直接切到该节点。
  ///
  /// 走 [MclashNodeSelector] 而不是写某个组 —— 全局模式下真正生效的是内核
  /// GLOBAL，写策略组等于没切（这正是「切了全局、选了节点却没反应」的根因）。
  Future<void> _selectFlatNode(ClashProxiesNode node) async {
    final err = await MclashNodeSelector.select(node.name);
    if (!mounted) {
      return;
    }
    if (err != null) {
      DialogUtils.showAlertDialog(context, err.message);
      return;
    }
    setState(() {
      for (final g in _nodes) {
        if (ClashProtocolType.GroupToList().contains(g.type)) {
          g.now = node.name;
        }
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("已切换到 ${node.name}")));
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
            if (!await _kernelReady()) {
              return;
            }
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

  Future<bool> _kernelReady() async {
    final probe = widget.kernelAlive;
    final alive = probe == null ? true : await probe();
    if (alive) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    await DialogUtils.showAlertDialog(
      context,
      "此操作需要内核运行：请先在「主页」打开连接开关，再回来操作。",
    );
    return false;
  }

  Future<void> delayTest({String nodeName = ""}) async {
    if (!await _kernelReady()) {
      return;
    }
    final setting = SettingManager.getConfig();
    _nodesTesting.clear();

    if (nodeName.isNotEmpty) {

      _nodesTesting.add(nodeName);
      _nodesTestTotal = 1;
    } else {

      for (final n in _delayTestTargets()) {
        _nodesTesting.add(n);
      }
      _nodesTestTotal = _nodesTesting.length;
    }
    if (_nodesTestTotal == 0) {

      widget.controller?.onTesting?.call();
      return;
    }
    widget.controller?.onTesting?.call();

    var nextIndex = 0;
    Future<void> testNext() async {
      while (nextIndex < _nodes.length) {
        final node = _nodes[nextIndex++];

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
