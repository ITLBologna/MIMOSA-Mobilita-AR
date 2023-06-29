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

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/models/apis/autocomplete_place.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_autocomplete_place_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_notification_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/location_uploader_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/user_access_controller.dart';
import 'package:mimosa/controllers/view_models/plan_trip_data.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/library_widgets/alert_dialog.dart';
import 'package:mimosa/ui/library_widgets/future_builder_enhanced.dart';
import 'package:mimosa/ui/pages/guide/guide_page_arguments.dart';
import 'package:mimosa/ui/widgets/home_cards/routes_card_widget.dart';
import 'package:mimosa/ui/widgets/home_cards/trip_card_widget.dart';
import 'package:mimosa/ui/widgets/map_attributions/attribution_link_widget.dart';
import 'package:mimosa/ui/widgets/shimmer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TraceableClientMixin {
  static const int _remindUseNotificationId = 3;
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  final locationUploaderService = LocationUploaderService();
  late final IApisService apiService;
  late final IConfigurationService iConfigService;
  late Future<Validation<String>> futureVersion;
  final userAccessController = Get.find<UserAccessController>();

  AutocompletePlace? selectedPlace;
  List<AutocompletePlace>? autocompletePlaces;
  String lastPattern = '';
  late final TextEditingController _textEditingController;
  late final ILocationService _locationService;
  final autocompletePlacesService =
      serviceLocator.get<IAutocompletePlaceService>();

  final locationService = serviceLocator.get<ILocationService>();
  final localStorageService = serviceLocator.get<ILocalStorage>();
  PlanTripData? planTripData;
  late final StreamSubscription keyboardSubscription;
  final ScrollController scrollController = ScrollController();

  void showErrorMessageInPostFrameCallback(
      BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showAlertDialogEx(context,
          progressIndicatorTag: 'initError',
          title: AppLocalizations.of(context)!.error,
          message: message);
    });
  }

  void _initLocationUploaderService(int uploadIntervalInSeconds) {
    locationUploaderService.init(
        localStorageService: localStorageService,
        apiService: apiService,
        uploadCheckIntervalInSeconds: uploadIntervalInSeconds,
        maxEntriesToUpload:
            iConfigService.settings.trackingSettings.maxEntriesToUpload);
  }

  void setRemindNotification() {
    final ln = serviceLocator.get<ILocalNotificationService>();
    final loc = AppLocalizations.of(context)!;

    ln.schedulePeriodicalNotification(
        id: _remindUseNotificationId,
        title: loc.remind_use_notification_title,
        body: loc.remind_use_notification_body,
        interval:
            iConfigService.settings.remindToUseNotificationRepeatInterval);
  }

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _locationService = serviceLocator.get<ILocationService>();

    final ln = serviceLocator.get<ILocalNotificationService>();
    ln.requestPermissions().then((value) {
      ln.cancelAllNotifications();
    });

    WidgetsBinding.instance.addObserver(this);
    final storage = serviceLocator.get<ILocalStorage>();
    storage.deleteAllGamificationsData();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      double offset = 0;
      if (visible) {
        key.currentState?.expand();
        offset = 100;
      }

      scrollToOffset() => scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
      if (offset == 0) {
        scrollToOffset();
      } else {
        Future.delayed(const Duration(milliseconds: 200), scrollToOffset);
      }
    });

    apiService = serviceLocator.get<IApisService>();
    iConfigService = serviceLocator.get<IConfigurationService>();

    _textEditingController.addListener(() {
      lastPattern = _textEditingController.text;
      _locationService
          .getLastPosition()
          .then((p) => autocompletePlacesService.getAutocompletePlaces(
              input: _textEditingController.text,
              location: LatLng(p.latitude, p.longitude)))
          .fold((failures) {
        return <AutocompletePlace>[];
      }, (val) => val).then(
              (value) => setState(() => autocompletePlaces = value));
    });

    if (iConfigService.settings.trackingSettings.enabled) {
      _initLocationUploaderService(iConfigService
          .settings.trackingSettings.uploadCheckIntervalInSeconds);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        userAccessController.access();

        Hive.openBox('startup')
            .then((value) => value.put('guide_completed', true));

        locationService
            .startTracking(
                notificationsIntervalInMillisec: iConfigService
                    .settings.trackingSettings.notificationsIntervalInMillisec,
                androidNotificationTitle:
                    AppLocalizations.of(context)!.android_notification_title,
                distanceFilterInMeters: iConfigService
                    .settings.trackingSettings.distanceFilterInMeters,
                minDistanceToTrackInMeters: iConfigService
                    .settings.trackingSettings.minDistanceToTrackInMeters,
                onError: (error) {
                  debugPrint('Error starting tracking: $error');
                  showErrorMessageInPostFrameCallback(
                      context, AppLocalizations.of(context)!.unable_to_track);
                },
                onLocationUpdate: (locationData) {
                  // localStorageService was initialized in main
                  Hive.openBox("settings").then((value) {
                    if ((value.get('noticeSuggestionsConsentAllowed',
                            defaultValue: null) as bool?) ==
                        true) {
                      localStorageService.storeLocationData(
                          locationData.time!.toString(), locationData.toMap());
                    }
                  });
                })
            .fold((failures) {
          debugPrint(
              'Error starting tracking: ${failures.map((e) => e.message).join(' | ')}');
          showErrorMessageInPostFrameCallback(
              context, AppLocalizations.of(context)!.unable_to_track);
        }, (val) {});

        setRemindNotification();
      });
    }
    futureVersion = serviceLocator.get<IConfigurationService>().initVersion();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {
      final ln = serviceLocator.get<ILocalNotificationService>();
      ln.cancelNotification(_remindUseNotificationId).then((value) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setRemindNotification();
        });
      });
    } else if (state == AppLifecycleState.detached) {
      return;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    locationService.stopTracking();

    _textEditingController.dispose();

    scrollController.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
              toolbarHeight: 100,
              centerTitle: false,
              title: GestureDetector(
                onTap: () {
                  showLicensePage(context: context);
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AutoSizeText(widget.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.black)),
                      FutureBuilderEnhanced(
                          future: futureVersion,
                          onDataLoaded: (version) {
                            var strVer = version != null
                                ? version.fold(
                                    (failures) => AppLocalizations.of(context)!
                                        .unknown_version,
                                    (val) => val)
                                : AppLocalizations.of(context)!.unknown_version;

                            return AutoSizeText(strVer,
                                style: Theme.of(context).textTheme.labelMedium);
                          })
                    ]),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Get.toNamed(guideCarouselRoute,
                          arguments: GuidePageArguments(false));
                    },
                    icon: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.question_mark,
                              size: 14, color: Colors.grey.shade600),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.circle_outlined,
                              size: 26,
                              color: Colors.grey.shade600,
                            ))
                      ],
                    )),
                StreamBuilder(
                    stream: userAccessController.userAccessResponseStream(),
                    builder: (context, snapshot) => snapshot.hasData
                        ? Container(
                            child: snapshot.data?.gamificationEnabled == true
                                ? IconButton(
                                    onPressed: () {
                                      Get.toNamed(leaderboardRoute);
                                    },
                                    icon: Image.asset(
                                        'assets/images/trophy_512.png',
                                        width: 18,
                                        height: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.color),
                                  )
                                : null)
                        : Container()),
                IconButton(
                    onPressed: () {
                      Get.toNamed(suggestionsRoute);
                    },
                    icon: Image.asset('assets/images/bulb_on.png',
                        width: 22,
                        height: 22,
                        color: Theme.of(context).textTheme.labelMedium?.color)),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: StreamBuilder(
                    stream: userAccessController.userAccessResponseStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                            child: Center(
                          child: Stack(children: [
                            IconButton(
                                onPressed: () => Get.toNamed(surveyRoute),
                                icon: Icon(
                                  FontAwesomeIcons.poll,
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.color,
                                )),
                            Positioned(
                                right: 8,
                                top: 8,
                                child: SizedBox(
                                    child: snapshot.data?.showablePoll !=
                                                null &&
                                            snapshot.data?.showablePoll != ''
                                        ? Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: Colors.red.shade600,
                                          )
                                        : null))
                          ]),
                        ));
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Center(
                            child: ShimmerWidget(
                              child: Container(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white)),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )
              ]),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TripCardWidget(onPressed: (PlanTripData planTripData) {
                          MatomoTracker.instance.trackEvent(
                              eventCategory: 'Trip',
                              action:
                                  "Go to place: ${planTripData.place.description}");
                          Get.toNamed(itinerariesPageRoute,
                              arguments: planTripData);
                        }),
                        RoutesCardWidget(onPressed: () {
                          MatomoTracker.instance.trackEvent(
                              eventCategory: 'Routes', action: 'Go to routes');
                          Get.toNamed(routesRoute);
                        }),
                        /*RoutesCardWidget(onPressed: () {
                              MatomoTracker.instance.trackEvent(
                                  eventCategory: 'Routes',
                                  action: 'Go to routes');
                              Get.toNamed(routesRoute);
                            }),*/
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
                bottom: true,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: LinkAttributionWidget(
                      text: AppLocalizations.of(context)!
                          .privacy_policy_link_text,
                      linkColor: null,
                      url:
                          '${const String.fromEnvironment('NOTICE_URL')}?lang=${AppLocalizations.of(context)!.localeName}'),
                ))
          ],
        ),
      ),
    );
  }

  @override
  String get traceName => 'HomePage';

  @override
  String get traceTitle => 'HomePage';
}
