// ignore_for_file: empty_catches, unused_catch_stack

import 'dart:io';

import 'package:mclash/app/modules/clash_setting_manager.dart';
import 'package:mclash/app/runtime/return_result.dart';
import 'package:mclash/app/utils/app_scheme_actions.dart';
import 'package:mclash/app/utils/backup_and_sync_utils.dart';
import 'package:mclash/app/utils/file_utils.dart';
import 'package:mclash/app/utils/network_utils.dart';
import 'package:mclash/app/utils/path_utils.dart';
import 'package:mclash/app/utils/qrcode_utils.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/backup_helper.dart';
import 'package:mclash/screens/dialog_utils.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';

class BackupAndSyncLanSyncScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "BackupAndSyncLanSyncScreen");
  }

  final String? title;
  const BackupAndSyncLanSyncScreen({super.key, required this.title});

  @override
  State<BackupAndSyncLanSyncScreen> createState() =>
      _BackupAndSyncLanSyncScreenState();
}

class _BackupAndSyncLanSyncScreenState
    extends LasyRenderingState<BackupAndSyncLanSyncScreen> {
  Image? _image;
  String? _zipPath;
  HttpServer? _server;
  Map<String, Tuple2<String, Function(HttpRequest httpRequest)>> _router = {};

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  void dispose() {
    stop();
    if (_zipPath != null) {
      FileUtils.deletePath(_zipPath!);
    }

    super.dispose();
  }

  Future<void> start() async {
    try {
      {
        String dir = await PathUtils.cacheDir();
        if (!mounted) {
          return;
        }
        _zipPath = path.join(dir, BackupAndSyncUtils.getZipFileName());
        ReturnResultError? error = await BackupHelper.backupToZip(
          context,
          _zipPath!,
        );
        if (error != null) {
          if (!mounted) {
            return;
          }
          DialogUtils.showAlertDialog(
            context,
            error.message,
            showCopy: true,
            showFAQ: true,
            withVersion: true,
          );
          return;
        }
      }
      var config = ClashSettingManager.getConfig();

      var ports = [config.MixedPort ?? 0, ClashSettingManager.getControlPort()];
      var listenPort = await NetworkUtils.getAvaliablePort(ports);
      if (listenPort == 0) {
        if (!mounted) {
          return;
        }
        DialogUtils.showAlertDialog(
          context,
          "BackupAndSyncLanSyncScreen.getAvaliablePort failed",
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
        return;
      }

      List<String> ips = [];
      var addrs = await NetworkUtils.getInterfaces();
      for (var addr in addrs) {
        if (addr.type != InternetAddressType.IPv4) {
          continue;
        }
        addr.name = addr.name.toLowerCase();
        if (addr.name.contains("VMWare".toLowerCase()) ||
            addr.name.contains("VirtualBox".toLowerCase()) ||
            addr.name.contains("VPN".toLowerCase()) ||
            addr.name.contains("tun".toLowerCase())) {
          continue;
        }
        ips.add(addr.address);
      }

      final action = AppSchemeActions.syncDownloadAction();

      String url =
          "${AppSchemeActions.scheme()}://$action/?ips=${Uri.encodeComponent(ips.join(","))}&port=$listenPort";
      url += "&filename=${Uri.encodeComponent(path.basename(_zipPath!))}";
      _image = QrcodeUtils.toImage(url).data;

      _server = await HttpServer.bind('0.0.0.0', listenPort);
      _server!.listen((req) async {
        switch (req.method) {
          case "GET":
          case "POST":
            _routing(path: req.uri.path, httpRequest: req);
            break;
          default:
            req.response.statusCode = HttpStatus.methodNotAllowed;
            req.response.close();
        }
      });

      _onRouting("/", "GET", (HttpRequest httpRequest) async {
        httpRequest.response.statusCode = HttpStatus.ok;
        httpRequest.response.close();
      });
      // 只保留「发送」方向：本机把备份**给出去**，对端随时来取。
      // 「接收」（对端把 zip 上传到本机、本机立刻恢复）已按产品要求移除 ——
      // 恢复只能靠登录账号重新同步订阅，不允许从外部把数据塞回来。
      _onRouting("/${AppSchemeActions.syncDownloadAction()}", "GET", (
        HttpRequest httpRequest,
      ) async {
        var file = File(_zipPath!);
        bool found = await file.exists();
        if (!found) {
          _sendNotFound(httpRequest.response);
          return;
        }
        var stream = file.openRead();
        await stream.pipe(httpRequest.response).catchError((e) {});
        httpRequest.response.close();
      });
      setState(() {});
    } catch (err, stacktrace) {
      if (!mounted) {
        return;
      }
      DialogUtils.showAlertDialog(
        context,
        err.toString(),
        showCopy: true,
        showFAQ: true,
        withVersion: true,
      );
      return;
    }
  }



  void _sendNotFound(HttpResponse response) {
    response.statusCode = HttpStatus.notFound;
    response.close();
  }

  void _sendServerInnerError(HttpResponse response) {
    response.statusCode = HttpStatus.internalServerError;
    response.close();
  }

  Future<void> stop() async {
    _router = {};
    if (_server != null) {
      await _server!.close();
      _server = null;
    }
  }

  void _onRouting(
    String routing,
    String method,
    Future<void> Function(HttpRequest httpRequest) callback,
  ) {
    _router[routing] = Tuple2(method, callback);
  }

  Future<void> _routing({String? path, HttpRequest? httpRequest}) async {
    if (httpRequest == null) {
      return;
    }
    var result = _router[path];
    if (result == null || result.item1 != httpRequest.method) {
      _sendNotFound(httpRequest.response);
      return;
    }
    try {
      await result.item2.call(httpRequest);
    } catch (err) {
      _sendServerInnerError(httpRequest.response);
      Future.delayed(const Duration(microseconds: 10), () async {
        if (!mounted) {
          return;
        }
        DialogUtils.showAlertDialog(
          context,
          err.toString(),
          showCopy: true,
          showFAQ: true,
          withVersion: true,
        );
      });
    }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
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
                      width: windowSize.width - 50 * 2,
                      child: Text(
                        widget.title!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: ThemeConfig.kFontWeightTitle,
                          fontSize: ThemeConfig.kFontSizeTitle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    children: [
                      Text(
                        tcontext.meta.lanSyncNotQuitTips,
                        style: const TextStyle(
                          fontWeight: ThemeConfig.kFontWeightListSubItem,
                          fontSize: ThemeConfig.kFontSizeListSubItem,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: _image ?? const SizedBox.shrink(),
                        ),
                      ),
                    ],
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
