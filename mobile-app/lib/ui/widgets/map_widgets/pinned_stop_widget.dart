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
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/controllers/next_runs_controller.dart';
import 'package:mimosa/controllers/pinned_stop_controller.dart';
import 'package:mimosa/controllers/user_access_controller.dart';
import 'package:mimosa/ui/widgets/annotations/trip_stop_annotation_widget.dart';
import 'package:mimosa/ui/widgets/gamification/trip_stop_annotation_gamification_widget.dart';

class PinnedStopWidget extends StatelessWidget implements PreferredSizeWidget {
  final Size size;
  final TripStop? stop;

  const PinnedStopWidget({required this.size, this.stop, super.key});

  @override
  Size get preferredSize => size;

  @override
  Widget build(BuildContext context) {
    if (stop == null) {
      return const SafeArea(child: SizedBox());
    }

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          final c = Get.find<PinnedStopController>();
          c.showInfo.value = !c.showInfo.value;
        },
        child: Container(
          height: size.height,
          color: Colors.red,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          stop!.stopName,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AutoSizeText(
                            '#${stop!.stopCode}',
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          final c = Get.find<PinnedStopController>();
                          c.showInfo.value = !c.showInfo.value;
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.info,
                            color: Colors.white, size: 40)),
                  ],
                ),
              ),
              Container(height: 6, color: const Color(0xFFCCCCCC))
            ],
          ),
        ),
      ),
    );
  }
}

class PinnedStopInfoWidget extends StatefulWidget {
  final TripStop stop;
  final MimosaRoute route;

  const PinnedStopInfoWidget(
      {required this.stop, required this.route, super.key});

  @override
  State<PinnedStopInfoWidget> createState() => _PinnedStopInfoWidgetState();
}

class _PinnedStopInfoWidgetState extends State<PinnedStopInfoWidget> {
  late final Timer timer;

  late final UserAccessController _userAccessController;

  @override
  void initState() {
    _userAccessController = Get.find<UserAccessController>();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final c = Get.find<PinnedStopController>();
        c.showInfo.value = !c.showInfo.value;
      },
      child: Container(
        color: Colors.white,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              RunsWidget(
                fullscreen: true,
                highlighted: false,
                tripKey: GlobalKey(),
                calculatedWidth: MediaQuery.of(context).size.width,
                containerWidth: MediaQuery.of(context).size.width,
                nextRunsController: Get.find<NextRunsController>(),
                nextRunsQueryData: NextRunsQueryData(
                    routeId: widget.route.id,
                    stopId: widget.stop.stopId,
                    nResults: 4),
              ),
              FutureBuilder(
                  future: _userAccessController.userAccessResponse,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data?.gamificationEnabled != true) {
                      return Container();
                    } else {
                      return TripStopAnnotationGamificationWidget(
                          key: ValueKey('${widget.stop.stopId}_gamy'),
                          isFullscreen: true,
                          lastUserPosition: Position(
                              latitude: widget.stop.stopLat,
                              longitude: widget.stop.stopLon,
                              timestamp: DateTime.now(),
                              accuracy: 0,
                              altitude: 0,
                              heading: 0,
                              speed: 0,
                              speedAccuracy: 0),
                          stop: widget.stop);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
