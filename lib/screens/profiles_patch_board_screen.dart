import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:mclash/app/modules/profile_patch_manager.dart';
import 'package:mclash/i18n/strings.g.dart';
import 'package:mclash/screens/profiles_patch_board_screen_widgets.dart';
import 'package:mclash/screens/theme_config.dart';
import 'package:mclash/screens/widgets/framework.dart';
import 'package:flutter/material.dart';

class ProfilesPatchBoardScreen extends LasyRenderingStatefulWidget {
  static RouteSettings routeSettings() {
    return const RouteSettings(name: "/");
  }

  const ProfilesPatchBoardScreen({super.key});

  @override
  State<ProfilesPatchBoardScreen> createState() =>
      _ProfilesPatchBoardScreenState();
}

class _ProfilesPatchBoardScreenState
    extends LasyRenderingState<ProfilesPatchBoardScreen>
    with WidgetsBindingObserver, AfterLayoutMixin {
  @override
  void initState() {
    super.initState();
    ProfilePatchManager.onEventAdd.add(_onAdd);
    ProfilePatchManager.onEventRemove.add(_onRemove);
    ProfilePatchManager.onEventUpdate.add(_onUpdate);
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {}

  @override
  void dispose() {
    ProfilePatchManager.onEventAdd.remove(_onAdd);
    ProfilePatchManager.onEventRemove.remove(_onRemove);
    ProfilePatchManager.onEventUpdate.remove(_onUpdate);
    super.dispose();
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
                      tcontext.meta.overwrite,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: ThemeConfig.kFontWeightTitle,
                        fontSize: ThemeConfig.kFontSizeTitle,
                      ),
                    ),
                  ),
                  ProfilePatchManager.updating.isNotEmpty
                      ? const Row(
                          children: [
                            SizedBox(width: 12),
                            SizedBox(
                              width: 26,
                              height: 26,
                              child: RepaintBoundary(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            SizedBox(width: 12),
                          ],
                        )
                      : InkWell(
                          onTap: () async {
                            onTapUpdateAll();
                          },
                          child: Tooltip(
                            message: tcontext.meta.update,
                            child: const SizedBox(
                              width: 50,
                              height: 30,
                              child: Icon(
                                Icons.cloud_download_outlined,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                  child: FutureBuilder(
                    future: getProfiles(),
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<List<ProfilePatchSetting>> snapshot,
                        ) {
                          List<ProfilePatchSetting> data = snapshot.hasData
                              ? snapshot.data!
                              : [];
                          return ProfilesPatchBoardScreenWidget(settings: data);
                        },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ProfilePatchSetting>> getProfiles() async {
    return ProfilePatchManager.getProfiles();
  }

  void onTapUpdateAll() async {
    await ProfilePatchManager.updateAll();
  }

  Future<void> _onAdd(String id) async {
    setState(() {});
  }

  Future<void> _onRemove(String id) async {
    setState(() {});
  }

  Future<void> _onUpdate(String id, bool finish) async {
    setState(() {});
  }
}
