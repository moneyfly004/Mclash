
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
