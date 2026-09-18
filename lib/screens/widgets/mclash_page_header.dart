library;

import 'package:flutter/material.dart';
import 'package:mclash/screens/theme_config.dart';

/// 二级页面顶部标题栏（「我的」「套餐」等页面共用）。
///
/// 为什么要有它：这几个页面的标题栏原来各写一份，而且都是
///
/// ```dart
/// if (_loading) SizedBox(width: 20, height: 20, child: 转圈)
/// else         SizedBox(width: 44, height: 44, child: 刷新图标)
/// ```
///
/// —— 两个状态**尺寸不同**，一次刷新头部就矮 24px，整页内容跟着上下跳。
/// 用户反馈「我的页面会出现 UI 抖动，帮我固定位置」就是这个原因。
/// 现在右侧功能位**永远是 44×44**：里面放转圈、放刷新图标、还是什么都不放，
/// 标题栏高度都不变，页面因此不跳。
///
/// 标题仍然靠左（与改版前一致），只把「会变高的那个位置」固定住。
class MclashPageHeader extends StatelessWidget {
  const MclashPageHeader({
    super.key,
    required this.title,
    this.onRefresh,
    this.loading = false,
  });

  final String title;

  /// 点刷新时回调；为空时右侧功能位**仍然占位**（只是不显示图标），
  /// 这样「有没有刷新按钮」也不会改变标题栏高度。
  final VoidCallback? onRefresh;

  final bool loading;

  /// 右侧功能位的固定边长。
  static const double slotSize = 44;

  /// 转圈尺寸（比占位小，视觉居中）。
  static const double spinnerSize = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: ThemeConfig.kFontWeightTitle,
                fontSize: ThemeConfig.kFontSizeTitle,
              ),
            ),
          ),
          // ⚠️ 固定尺寸的功能位：加载态 / 完成态 / 无刷新按钮，三种情况都占同样大小，
          // 页面高度因此永远不变（这是「UI 抖动」的根因修复）。
          SizedBox(
            width: slotSize,
            height: slotSize,
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: spinnerSize,
                      height: spinnerSize,
                      child: RepaintBoundary(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : (onRefresh == null
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: onRefresh,
                          child: const Center(
                            child: Icon(Icons.refresh, size: 26),
                          ),
                        )),
          ),
        ],
      ),
    );
  }
}
