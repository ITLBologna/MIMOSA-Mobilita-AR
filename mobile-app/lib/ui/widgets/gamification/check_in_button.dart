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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/gamification_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckInButton extends StatelessWidget {
  final GamificationController gamificationController;
  final configService = serviceLocator.get<IConfigurationService>();
  final TripStop stop;
  final VoidCallback onPressed;

  CheckInButton(
      {required this.gamificationController,
      required this.stop,
      required this.onPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.asset(
                        'assets/images/trophy_512.png',
                        width: 40,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                loc.check_in,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                  onPressed: () {
                    gamificationController
                        .checkIn(stop,
                            tripPlannerInitialStop: gamificationController
                                .otpFirstStop,
                            tripPlannerLastStop: gamificationController
                                .otpLastStop,
                            notificationTitle: loc
                                .remind_play_notification_title,
                            notificationBody:
                                gamificationController.otpLastStop != null
                                    ? loc.remind_otp_play_notification_body(
                                        gamificationController
                                            .otpLastStop!.stopCode,
                                        gamificationController
                                            .otpLastStop!.stopName)
                                    : loc.remind_play_notification_body,
                            notifyAfter: Duration(
                                minutes: configService
                                    .settings
                                    .gamificationSettings
                                    .remindPlayNotificationAfterMinutes))
                        .fold((failures) => null, (val) => null);
                    onPressed();
                  },
                  child: Text(loc.check_in_start)),
            ],
          ),
        ));
  }
}
