
library;

import 'package:flutter/widgets.dart';
import 'package:mclash/app/utils/app_lifecycle_state_notify.dart';
import 'package:mclash/screens/widgets/routes.dart';

class RenderVisibility extends InheritedWidget {
  const RenderVisibility({
    super.key,
    required this.visible,
    required super.child,
  });

  final bool visible;

  static bool of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RenderVisibility>();
    return scope?.visible ?? true;
  }

  @override
  bool updateShouldNotify(RenderVisibility oldWidget) =>
      oldWidget.visible != visible;
}

abstract class LasyRenderingStatefulWidget extends StatefulWidget {
  const LasyRenderingStatefulWidget({super.key});
}

abstract class LasyRenderingState<T extends LasyRenderingStatefulWidget>
    extends State<T> {
  late int _hashCode;
  bool _needRedraw = false;

  bool _routeCurrent = true;
  bool _tabVisible = true;

  bool get _renderActive => _routeCurrent && _tabVisible;

  @override
  void initState() {
    super.initState();
    _hashCode = Object.hashAll([this, this]);
    AppLifecycleStateNofity.onStateResumed(_hashCode, () async {
      _tryRedraw("onStateResumed");
    });
    AppRouteObserver.instance.pushRoute(_hashCode);
    AppRouteObserver.instance.onRouteChanged(_hashCode, () {
      _tryRedraw("onRouteChanged");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeCurrent = ModalRoute.isCurrentOf(context) ?? true;
    final tabVisible = RenderVisibility.of(context);
    final becameActive = !_renderActive && routeCurrent && tabVisible;
    _routeCurrent = routeCurrent;
    _tabVisible = tabVisible;
    if (becameActive) {
      _tryRedraw("becameVisible");
    }
  }

  @override
  void dispose() {
    AppLifecycleStateNofity.onStateResumed(_hashCode, null);
    AppRouteObserver.instance.onRouteChanged(_hashCode, null);
    AppRouteObserver.instance.popRoute(_hashCode);

    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    if (AppLifecycleStateNofity.isPaused() || !_renderActive) {

      _print("delay redraw:${T.toString()} $hashCode "
          "paused=${AppLifecycleStateNofity.isPaused()} "
          "route=$_routeCurrent tab=$_tabVisible");
      fn();
      _needRedraw = true;
      _scheduleFlushCheck();
      return;
    }
    _print("redraw by setState:${T.toString()} $hashCode");
    _needRedraw = false;
    super.setState(fn);
  }

  void _tryRedraw(String from) {
    if (!mounted || !_needRedraw || !_renderActive) {
      return;
    }
    _print("redraw by $from :${T.toString()} $hashCode");
    _needRedraw = false;
    super.setState(() {});
  }

  void _scheduleFlushCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_needRedraw) {
        return;
      }
      if (_routeCurrent && _tabVisible && !AppLifecycleStateNofity.isPaused()) {
        _tryRedraw("postFrame");
      }
    });
  }

  void _print(Object? object) {

  }
}
