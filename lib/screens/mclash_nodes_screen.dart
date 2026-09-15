/// T-1 · 节点列表（一级 Tab 根页）
///
/// 直接复用 Clash Mi 的 `ProxyBoardScreen(tabRoot: true)`：
/// 它已经实现了延迟色阶（<800 绿 / <1500 中性 / ≥1500 红）、排序切换、
/// 批量测速（环内计数）、节点热切换、失效节点提示等**全部行为**。
/// 这里只做 Tab 根页的入口封装，避免出现两套实现导致行为分叉。
///
/// 代理组链路（代理组列表 → 组详情 → 节点多选）仍走原来的 push 路由，
/// 入口在「主页 → 代理」与内核设置里，**未被本 Tab 取代**。
library;

import 'package:flutter/material.dart';
import 'package:mclash/screens/proxy_board_screen.dart';

class MclashNodesScreen extends StatelessWidget {
  const MclashNodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProxyBoardScreen(tabRoot: true);
  }
}
