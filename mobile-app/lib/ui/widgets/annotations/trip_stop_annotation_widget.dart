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

import 'dart:math';

import 'package:ar_location_view/ar_annotation.dart';
import 'package:ar_location_view/ar_fullscreen_annotation_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/next_runs/run.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/controllers/gamification_controller.dart';
import 'package:mimosa/controllers/next_runs_controller.dart';
import 'package:mimosa/controllers/user_access_controller.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:mimosa/ui/library_widgets/future_builder_enhanced.dart';
import 'package:mimosa/ui/widgets/gamification/trip_stop_annotation_gamification_widget.dart';
import 'package:mimosa/ui/widgets/next_run_waiting_widget.dart';
import 'package:mimosa/ui/widgets/trip_info_widget.dart';

class TripStopAnnotationWidget extends StatefulWidget {
  final ArAnnotation<TripStop> annotation;
  final bool navigatingTo;
  final void Function() onNavigate;
  final double userSpeedInMetersPerSecond;
  final MimosaRoute route;
  final Trip trip;
  final GlobalKey arWidgetKey;
  final Position? lastUserPosition;

  const TripStopAnnotationWidget(
      {super.key,
      required this.route,
      required this.trip,
      required this.annotation,
      required this.userSpeedInMetersPerSecond,
      required this.arWidgetKey,
      required this.navigatingTo,
      required this.onNavigate,
      this.lastUserPosition});

  @override
  State<TripStopAnnotationWidget> createState() =>
      _TripStopAnnotationWidgetState();
}

class _TripStopAnnotationWidgetState extends State<TripStopAnnotationWidget> {
  final GlobalKey _tripKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  late ArFullscreenAnnotationController _fullscreenAnnotationUIController;
  late final NextRunsController _nextRunsController;
  late final GamificationController _gamificationController;
  late final UserAccessController _userAccessController;
  late NextRunsQueryData nextRunsQueryData;
  double? calculatedWidth;
  double? preFullScreenWidth;
  double? lastCalculatedWidth;
  double? arWidgetHeight;

  @override
  void initState() {
    super.initState();
    nextRunsQueryData = NextRunsQueryData(
        routeId: widget.route.id,
        stopId: widget.annotation.data.stopId,
        nResults: 6);
    _nextRunsController = Get.find<NextRunsController>();
    _gamificationController = Get.find<GamificationController>();
    _fullscreenAnnotationUIController =
        Get.find<ArFullscreenAnnotationController>();
    _userAccessController = Get.find<UserAccessController>();
    if (!(widget.annotation.angle.abs() < 15 &&
        widget.annotation.highlighted &&
        widget.annotation.distanceFromUserInMeters < 10)) {
      _getSizeAndPosition();
    }
  }

  _getSizeAndPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripBox = _tripKey.currentContext?.findRenderObject() as RenderBox?;
      final headerBox =
          _headerKey.currentContext?.findRenderObject() as RenderBox?;
      if (tripBox != null && headerBox != null) {
        setState(() {
          bool fullscreen =
              _fullscreenAnnotationUIController.annotationUid.value ==
                      widget.annotation.data.stopId &&
                  widget.annotation.angle.abs() < 15;
          if (!fullscreen) {
            lastCalculatedWidth = max(tripBox.size.width, headerBox.size.width);
          }
          arWidgetHeight = widget.arWidgetKey.currentContext?.size?.height;
        });
      }
    });
  }

  void _removeFullScreen() {
    // We need to add a post frame because settings annotationUid value fires another UI update and cannot be done
    // while building UI
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_fullscreenAnnotationUIController.annotationUid.value ==
          widget.annotation.data.stopId) {
        _fullscreenAnnotationUIController.annotationUid.value = '';
      }
    });
  }

  String _getDurationInMinutesAndSecond(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds - (duration.inMinutes * 60);

    return '${minutes.toString()} min ${seconds.toString()} s';
  }

  String _getDepartureTimeString(BuildContext context, Duration? duration) {
    if (duration != null) {
      return _getDurationInMinutesAndSecond(duration);
    }

    return AppLocalizations.of(context)!.unavailable_departure_time;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = arWidgetHeight ?? MediaQuery.of(context).size.height;

    if (arWidgetHeight == null) {
      _getSizeAndPosition();
    }

    double? containerWidth;
    double? containerHeigth;
    double borderRadius;
    BoxBorder? border;
    bool fullscreen = _fullscreenAnnotationUIController.annotationUid.value ==
        widget.annotation.data.stopId;

    if (fullscreen) {
      const topOffset = 50.0;
      const bottomOffset = 30.0;
      const leftRightOffset = 20.0;

      borderRadius = 10;
      widget.annotation.arPosition = const Offset(leftRightOffset, topOffset);
      widget.annotation.customPositioned = true;
      containerWidth = width - (leftRightOffset * 2);
      containerHeigth = height - (topOffset + bottomOffset);

      calculatedWidth = double.infinity;
    } else {
      _removeFullScreen();
      calculatedWidth = lastCalculatedWidth;

      borderRadius = 5;
      border = Border.all(
          color: widget.annotation.highlighted
              ? Theme.of(context).primaryColor
              : Colors.black26,
          width: widget.annotation.highlighted ? 2 : 0.3);
      widget.annotation.customPositioned = false;
    }

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      color: Colors.white,
    );

    Color color = Colors.red;
    if (widget.navigatingTo) {
      color = directionsColor;
    } else if (widget.annotation.isGrayed) {
      color = Colors.grey;
    }

    final onFootDuration = Duration(
        seconds: widget.annotation.distanceFromUserInMeters ~/
            widget.userSpeedInMetersPerSecond);
    final onFootTimeStr = _getDepartureTimeString(context, onFootDuration);

    return Opacity(
      opacity: fullscreen ? 1.0 : 0.85,
      child: GestureDetector(
        onTap: () {
          if (fullscreen) {
            _removeFullScreen();
          } else {
            _fullscreenAnnotationUIController.annotationUid.value =
                widget.annotation.data.stopId;
          }
        },
        child: IntrinsicWidth(
          child: Container(
            width: containerWidth,
            decoration: decoration,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        key: _headerKey,
                        color: color,
                        padding: const EdgeInsets.all(10.0),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: AutoSizeText(
                                    '#${widget.annotation.data.stopCode}',
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                AutoSizeText(
                                  widget.annotation.data.stopName,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                            if (fullscreen)
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                      padding: const EdgeInsets.only(left: 16),
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        if (!widget.navigatingTo) {
                                          _removeFullScreen();
                                        }
                                        widget.onNavigate();
                                      },
                                      icon: const Icon(
                                          Icons.assistant_navigation,
                                          color: Colors.white)))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: Text(
                          AppLocalizations.of(context)!
                              .trip_stop_annotation_distance_to_stop(
                                  widget.annotation.distanceFromUserInMeters
                                      .toInt(),
                                  onFootTimeStr),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: RunsWidget(
                        fullscreen: fullscreen,
                        highlighted: widget.annotation.highlighted,
                        distanceFromUserInMeters:
                            widget.annotation.distanceFromUserInMeters,
                        userSpeedInMetersPerSecond:
                            widget.userSpeedInMetersPerSecond,
                        tripKey: _tripKey,
                        calculatedWidth: calculatedWidth,
                        containerWidth: containerWidth,
                        nextRunsController: _nextRunsController,
                        nextRunsQueryData: nextRunsQueryData,
                      ),
                    ),
                  ],
                ),
                if (_gamificationController.otpFirstStop == null ||
                    _gamificationController.otpFirstStop?.stopId ==
                        widget.annotation.data.stopId ||
                    _gamificationController.otpLastStop?.stopId ==
                        widget.annotation.data.stopId)
                  FutureBuilder(
                      future: _userAccessController.userAccessResponse,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data?.gamificationEnabled != true) {
                          return Container();
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: TripStopAnnotationGamificationWidget(
                                    key: ValueKey(
                                        '${widget.annotation.data.stopId}_gamy'),
                                    isFullscreen: fullscreen,
                                    lastUserPosition: widget.lastUserPosition,
                                    stop: widget.annotation.data),
                              ),
                            ],
                          );
                        }
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RunsWidget extends StatelessWidget {
  final bool fullscreen;
  final bool highlighted;
  final double? calculatedWidth;
  final double? containerWidth;
  final NextRunsController nextRunsController;
  final NextRunsQueryData nextRunsQueryData;
  final double? userSpeedInMetersPerSecond;
  final double? distanceFromUserInMeters;
  final GlobalKey tripKey;

  const RunsWidget(
      {super.key,
      required this.fullscreen,
      required this.highlighted,
      required this.calculatedWidth,
      required this.containerWidth,
      required this.nextRunsController,
      this.userSpeedInMetersPerSecond,
      this.distanceFromUserInMeters,
      required this.tripKey,
      required this.nextRunsQueryData});

  @override
  Widget build(BuildContext context) {
    if (fullscreen || highlighted) {
      return nextRunsController.isCacheExpired(nextRunsQueryData)
          ? FutureBuilderEnhanced(
              future: nextRunsController.getRuns(nextRunsQueryData),
              progressIndicator: NextRunWaitingWidget(
                size: calculatedWidth == double.infinity
                    ? containerWidth
                    : calculatedWidth,
                fullscreen: fullscreen,
                padding: fullscreen ? 15 : 8,
              ),
              onDataLoaded: (data) {
                return data!.fold((failures) => Container(), (runs) {
                  return Container(); // Doesn't matter the widget we return. It will be replaced by RunsListWidget next screen update
                });
              },
            )
          : RunsListWidget(
              runs: nextRunsController.getValidRuns(nextRunsQueryData),
              fullscreen: fullscreen,
              highlighted: highlighted,
              distanceFromUserInMeters: distanceFromUserInMeters,
              userSpeedInMetersPerSecond: userSpeedInMetersPerSecond,
              tripKey: tripKey,
              calculatedWidth: 400 ?? calculatedWidth);
    } else {
      return Container();
    }
  }
}

class RunsListWidget extends StatelessWidget {
  final List<Run> runs;
  final bool fullscreen;
  final bool highlighted;
  final double? userSpeedInMetersPerSecond;
  final double? distanceFromUserInMeters;
  final GlobalKey tripKey;
  final double? calculatedWidth;

  const RunsListWidget(
      {super.key,
      required this.runs,
      required this.fullscreen,
      required this.highlighted,
      this.userSpeedInMetersPerSecond,
      this.distanceFromUserInMeters,
      required this.tripKey,
      this.calculatedWidth});

  @override
  Widget build(BuildContext context) {
    if (highlighted || fullscreen) {
      if (runs.isEmpty) {
        return Container();
      }

      return fullscreen
          ? LimitedBox(
              key: tripKey,
              maxWidth: calculatedWidth ?? MediaQuery.of(context).size.width,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: min(4, runs.length),
                  itemBuilder: (context, index) {
                    return Container(
                      width: calculatedWidth,
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 20, top: 8),
                      child: TripInfoWidget(
                          route: runs[index].route,
                          trip: runs[index].trip,
                          scheduledDepartureTime: runs[index].scheduledTime,
                          liveDepartureTime: runs[index].liveTime,
                          userSpeedInMetersPerSecond:
                              userSpeedInMetersPerSecond,
                          distanceFromUser: distanceFromUserInMeters,
                          isExpanded: fullscreen),
                    );
                  }),
            )
          : Container(
              key: tripKey,
              padding: const EdgeInsets.all(10),
              child: TripInfoWidget(
                  route: runs.first.route,
                  trip: runs.first.trip,
                  scheduledDepartureTime: runs.first.scheduledTime,
                  liveDepartureTime: runs.first.liveTime,
                  userSpeedInMetersPerSecond: userSpeedInMetersPerSecond,
                  distanceFromUser: distanceFromUserInMeters,
                  isExpanded: fullscreen),
            );
    } else {
      return Container();
    }
  }
}
