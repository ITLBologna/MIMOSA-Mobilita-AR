/*
 * Copyright 2022-2023 bitApp S.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Mimosa APP
 *
 *
 * Contact: info@bitapp.it
 *  
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mimosa/controllers/permissions_controller.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/pages/guide/guide_carousel_page_indicator.dart';
import 'package:mimosa/ui/pages/guide/guide_page.dart';
import 'package:mimosa/ui/pages/guide/guide_page_arguments.dart';
import 'package:mimosa/ui/pages/guide/slides/all_set_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/ar_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/consent_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/gamification_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/general_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/greetings_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/notice_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/notifications_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/routes_and_trips_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/tos_guide_slide.dart';
import 'package:permission_handler/permission_handler.dart';

class GuideCarouselPage extends StatefulWidget {
  const GuideCarouselPage({Key? key}) : super(key: key);

  @override
  State<GuideCarouselPage> createState() => _GuideCarouselPageState();
}

class _GuideCarouselPageState extends State<GuideCarouselPage> {
  late PageController pageController;
  PermissionsController permissionsController = Get.find();
  int? currentPageIndex = 0;

  bool hasInteractedWithTos = false;
  bool hasInteractedWithLocationPermission = false;
  bool hasInteractedWithCameraPermission = false;
  bool hasInteractedWithActivityRecognitionPermission = false;
  bool hasInteractedWithNotificationsPermission = false;
  bool hasInteractedWithTrackingRequest = false;

  bool trackingSnackbarShowing = false;

  late List<Widget> pages;
  late Future<List<Widget>> futurePages;

  @override
  void initState() {
    super.initState();

    futurePages = Hive.openBox('settings').then((value) {
      bool? noticeSuggestionsConsentAllowed =
          value.get('noticeSuggestionsConsentAllowed', defaultValue: false);
      bool? noticeGamificationConsentAllowed =
          value.get('noticeGamificationConsentAllowed', defaultValue: false);
      bool? noticePollsConsentAllowed =
          value.get('noticePollsConsentAllowed', defaultValue: false);

      List<String> selectedOptions = [];
      if (noticeSuggestionsConsentAllowed == true) {
        selectedOptions.add('suggestions');
      }

      if (noticeGamificationConsentAllowed == true) {
        selectedOptions.add('gamification');
      }

      if (noticePollsConsentAllowed == true) {
        selectedOptions.add('survey');
      }

      return pages = [
        GreetingsGuideSlide().page(),
        TosGuideSlide(
                onAgreeClick: () {
                  _goToNextOrFinish();
                },
                accepted: hasInteractedWithTos)
            .page(),
        NoticeGuideSlide(onContinueClick: () {
          _goToNextOrFinish();
        }).page(),
        GeneralGuideSlide().page(),
        RoutesAndTripsGuideSlide().page(),
        ArGuideSlide().page(),
        ConsentGuideSlide(
                selectedOptions: selectedOptions,
                onConsentOptionSelected: _onConsentOptionSelected)
            .page(),
        GamificationGuideSlide().page(),
        if (Platform.isAndroid) NotificationsGuideSlide().page(),
        AllSetGuideSlide().page()
      ];
    });

    permissionsController.updateMimosaPermissionStatus();

    permissionsController.mps().listen((event) {
      MimosaPermissionStatus mp = event;

      if (mp.locationPermissionStatus == PermissionStatus.granted ||
          mp.locationPermissionStatus == PermissionStatus.permanentlyDenied) {
        hasInteractedWithLocationPermission = true;
      }

      if (mp.cameraPermissionStatus == PermissionStatus.granted ||
          mp.cameraPermissionStatus == PermissionStatus.permanentlyDenied) {
        hasInteractedWithCameraPermission = true;
      }

      if (mp.activityRecognitionPermissionStatus == PermissionStatus.granted ||
          mp.activityRecognitionPermissionStatus ==
              PermissionStatus.permanentlyDenied) {
        hasInteractedWithActivityRecognitionPermission = true;
      }

      if (mp.notificationPermissionStatus == PermissionStatus.granted ||
          mp.notificationPermissionStatus ==
              PermissionStatus.permanentlyDenied) {
        hasInteractedWithNotificationsPermission = true;
      }
    });

    pageController = PageController()
      ..addListener(() {
        setState(() {
          currentPageIndex = pageController.page?.round() ?? 0;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as GuidePageArguments;

    return FutureBuilder(
      future: futurePages,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final pgs = _getPages(args.firstOpening);

          return Scaffold(
              body: Container(
                  color: Colors.white,
                  child: PageView.builder(
                      controller: pageController,
                      physics: _getScrollPhysics(
                          args.firstOpening, pgs, currentPageIndex, {
                        'location': hasInteractedWithLocationPermission,
                        'camera': hasInteractedWithCameraPermission,
                        'activityRecognition':
                            hasInteractedWithActivityRecognitionPermission,
                        'notifications':
                            hasInteractedWithNotificationsPermission,
                        'tos': hasInteractedWithTos,
                      }),
                      itemCount: pgs.length,
                      itemBuilder: (_, i) {
                        return pgs[i];
                      })),
              bottomNavigationBar: Container(
                color: context.theme.primaryColor,
                child: SafeArea(
                  child: Container(
                    color: context.theme.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Opacity(
                            opacity:
                                ((currentPageIndex ?? 0) < pgs.length - 1) &&
                                        !args.firstOpening
                                    ? 1
                                    : ((currentPageIndex ?? 0) == 0 ? 0 : 1),
                            child: InkWell(
                              onTap: () {
                                if (args.firstOpening) return;
                                pageController.animateToPage(pgs.length - 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                              },
                              child: args.firstOpening &&
                                      (currentPageIndex ?? 0) > 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0),
                                      child: IconButton(
                                          alignment: Alignment.centerLeft,
                                          onPressed: () {
                                            _goToPrevious();
                                          },
                                          icon: const Icon(
                                            Icons.arrow_back_ios_rounded,
                                            size: 24,
                                          )),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: Text(
                                        AppLocalizations.of(context)
                                                ?.guide_skip_button ??
                                            '',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: GuideCarouselPageIndicator(
                            totalPages: pgs.length,
                            currentPageIndex: currentPageIndex ?? 1,
                            currentIndicatorColor: Colors.black,
                            indicatorColor: Colors.black.withAlpha(80),
                          ),
                        ),
                        if ((currentPageIndex ?? 0) < pgs.length - 1)
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Opacity(
                                  opacity: _getArrowNextVisibility(
                                          currentPageIndex,
                                          pgs.length,
                                          pgs[currentPageIndex ?? 0]
                                              as IGuidePage)
                                      ? 1
                                      : 0,
                                  child: IconButton(
                                      onPressed: () {
                                        if (!args.firstOpening) {
                                          _goToNextOrFinish();
                                          return;
                                        }

                                        IGuidePage pg =
                                            pgs[currentPageIndex ?? 0]
                                                as IGuidePage;
                                        if (pg.requireInteractionBeforeNextPage &&
                                            pg.pageName == 'location' &&
                                            !hasInteractedWithLocationPermission) {
                                          Permission.location.request().then(
                                              (value) => _goToNextOrFinish());
                                          return;
                                        } else if (pg
                                                .requireInteractionBeforeNextPage &&
                                            pg.pageName == 'camera' &&
                                            !hasInteractedWithCameraPermission) {
                                          Permission.camera.request().then(
                                              (value) => _goToNextOrFinish());
                                          return;
                                        } else if (pg
                                                .requireInteractionBeforeNextPage &&
                                            pg.pageName ==
                                                'activityRecognition' &&
                                            !hasInteractedWithActivityRecognitionPermission) {
                                          (Platform.isAndroid
                                                  ? Permission
                                                      .activityRecognition
                                                      .request()
                                                  : Permission.sensors
                                                      .request())
                                              .then((value) =>
                                                  _goToNextOrFinish());
                                          return;
                                        } else if (pg
                                                .requireInteractionBeforeNextPage &&
                                            pg.pageName == 'notifications' &&
                                            !hasInteractedWithNotificationsPermission) {
                                          Permission.notification
                                              .request()
                                              .then((value) =>
                                                  _goToNextOrFinish());
                                          return;
                                        } else if (pg
                                                .requireInteractionBeforeNextPage &&
                                            pg.pageName == 'tos' &&
                                            !hasInteractedWithTos) {
                                          // do nothing
                                        } else if (pg.pageName == 'notice') {
                                          // do nothing
                                        } else {
                                          _goToNextOrFinish();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 24,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        if ((currentPageIndex ?? 0) >= pgs.length - 1)
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: InkWell(
                              onTap: () => Get.offAllNamed(homeRoute),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 0.0),
                                child: Text(
                                  textAlign: TextAlign.end,
                                  AppLocalizations.of(context)
                                          ?.guide_start_button ??
                                      '',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ));
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  void _onConsentOptionSelected(List<String>? options) {
    Hive.openBox('settings').then((value) {
      if (options?.contains('suggestions') ?? false) {
        value.put('noticeSuggestionsConsentAllowed', true);
      } else {
        value.put('noticeSuggestionsConsentAllowed', false);
      }

      if (options?.contains('gamification') ?? false) {
        value.put('noticeGamificationConsentAllowed', true);
      } else {
        value.put('noticeGamificationConsentAllowed', false);
      }

      if (options?.contains('survey') ?? false) {
        value.put('noticePollsConsentAllowed', true);
      } else {
        value.put('noticePollsConsentAllowed', false);
      }
    });
  }

  void _goToPrevious() {
    pageController.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  void _goToNextOrFinish() {
    pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  List<Widget> _getPages(bool firstOpening) {
    return pages
        .where((element) => firstOpening
            ? true
            : (element as IGuidePage).showIfNotFirstTime == true)
        .toList();
  }

  ScrollPhysics _getScrollPhysics(bool firstOpening, List<Widget> pages,
      int? currentPageIndex, Map<String, bool> hasInteractedWith) {
    int pageIndex = currentPageIndex ?? 0;
    IGuidePage page = pages[pageIndex] as IGuidePage;

    if (!firstOpening) return const AlwaysScrollableScrollPhysics();

    if (page.requireInteractionBeforeNextPage &&
            (page.pageName == 'location' &&
                hasInteractedWith['location'] == false) ||
        (page.pageName == 'camera' && hasInteractedWith['camera'] == false) ||
        (page.pageName == 'activityRecognition' &&
            hasInteractedWith['activityRecognition'] == false) ||
        (page.pageName == 'notifications' &&
            hasInteractedWith['notfications'] == false) ||
        (page.pageName == 'tos' ||
            page.pageName == 'notice' ||
            page.pageName == 'consent')) {
      return const NeverScrollableScrollPhysics();
    }

    return const AlwaysScrollableScrollPhysics();
  }

  bool _getArrowNextVisibility(
      int? currentPageIndex, int totalPages, IGuidePage currentPage) {
    return currentPage.pageName != 'tos' && currentPage.pageName != 'notice';
  }
}
