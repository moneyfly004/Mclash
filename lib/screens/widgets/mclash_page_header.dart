library;

import 'package:flutter/material.dart';
import 'package:mclash/screens/theme_config.dart';

class MclashPageHeader extends StatelessWidget {
  const MclashPageHeader({
    super.key,
    required this.title,
    this.onRefresh,
    this.loading = false,
  });

  final String title;

  final VoidCallback? onRefresh;

  final bool loading;

  static const double slotSize = 44;

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
