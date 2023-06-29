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

import 'package:ar_location_view/services/process_sensors_data_service.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/models/apis/claim_prize_response.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/gamification_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mimosa/controllers/user_access_controller.dart';
import 'package:mimosa/controllers/vibrate_controller.dart';
import 'package:mimosa/ui/widgets/gamification/check_in_button.dart';
import 'package:mimosa/ui/widgets/gamification/check_out_button.dart';
import 'package:mimosa/ui/widgets/gamification/check_out_pulsing_cup_widget.dart';
import 'package:mimosa/ui/widgets/gamification/goto_another_stop_widget.dart';
import 'package:mimosa/ui/widgets/gamification/playing_token_widget.dart';

class TripStopAnnotationGamificationWidget extends StatefulWidget {
  final Position? lastUserPosition;
  final TripStop stop;
  final bool isFullscreen;

  const TripStopAnnotationGamificationWidget({
    required this.isFullscreen,
    required this.stop,
    this.lastUserPosition,
    super.key
  });

  @override
  State<TripStopAnnotationGamificationWidget> createState() => _TripStopAnnotationGamificationWidgetState();
}

class _TripStopAnnotationGamificationWidgetState extends State<TripStopAnnotationGamificationWidget> {
  final gamificationController = Get.find<GamificationController>();
  final userAccessController = Get.find<UserAccessController>();
  late final ConfettiController _confettiController;
  late Widget animatedWidget;
  late final IConfigurationService _settingsService;

  @override
  void initState() {
    _settingsService = serviceLocator.get<IConfigurationService>();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    const gotoAnotherStop = GotoAnotherStopWidget();

    final checkInButton = CheckInButton(
      gamificationController: gamificationController,
      stop: widget.stop,
      onPressed: () {
        setState(() {
          animatedWidget = gotoAnotherStop;
        });
      },
    );

    const waitingCheckout = Center(child: PlayingTokenWidget(tapEnabled: false,));

    final checkOutButton = CheckOutButton(
      gamificationController: gamificationController,
      userAccessController: userAccessController,
      stop: widget.stop,
    );

    final checkOutInErrorButton = CheckOutButton(
      gamificationController: gamificationController,
      userAccessController: userAccessController,
      stop: widget.stop,
      claimPrizeFailed: true,
    );

    onCheckout(Future<Validation<ClaimPrizeResponse>> futureClaimResponse) {
      setState(() {
        animatedWidget = waitingCheckout;
        futureClaimResponse.fold(
            (failures) {
              setState(() {
                animatedWidget = checkOutInErrorButton;
              });
            },
            (response) {
              setState(() {
                _confettiController.play();
                VibrateController.vibrate(500);
                animatedWidget = CheckoutPulsingCupWidget(
                  collectedPoints: response.points,
                  onAnimationEnded: () {
                    Future.delayed(const Duration(seconds: 2), () =>
                      setState(() {
                        animatedWidget = checkInButton;
                      })
                    );
                  },
                );
              });
            }
        );
      });
    }

    checkOutButton.onPressed = (futureClaimResponse) => onCheckout(futureClaimResponse);
    checkOutInErrorButton.onPressed = (futureClaimResponse) => onCheckout(futureClaimResponse);

    if(gamificationController.checkedInStop?.id == widget.stop.stopId) {
      animatedWidget = gotoAnotherStop;
    }
    else if(gamificationController.userIsPlaying.value) {
      animatedWidget = checkOutButton;
    }
    else {
      animatedWidget = checkInButton;
    }
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? distance = widget.lastUserPosition == null
                        ? null
                        : Geolocator.distanceBetween(
                            widget.lastUserPosition!.latitude,
                            widget.lastUserPosition!.longitude,
                            widget.stop.stopLat,
                            widget.stop.stopLon
                        );
    final sensorsService = Get.find<ProcessSensorsDataService>();
    if(widget.isFullscreen && distance != null &&
        distance <= (_settingsService.settings.gamificationSettings.checkInCheckOutMaxDistanceInMeters + sensorsService.getUserPositionAccuracy())) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1500),
            child: animatedWidget,
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            gravity: 1,
            emissionFrequency: 0.3,
            numberOfParticles: 10,
            minBlastForce: 8,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,)
        ],
      );
    }
    else {
      return Container();
    }
  }
}