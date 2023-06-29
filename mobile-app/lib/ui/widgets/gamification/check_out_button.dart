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
import 'package:flutter/services.dart';
import 'package:mimosa/business_logic/models/apis/claim_prize_response.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/controllers/gamification_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mimosa/controllers/user_access_controller.dart';

class CheckOutButton extends StatelessWidget {
  final GamificationController gamificationController;
  final UserAccessController userAccessController;
  final TripStop stop;
  final bool claimPrizeFailed;
  void Function(Future<Validation<ClaimPrizeResponse>>)? onPressed;

  CheckOutButton(
      {required this.gamificationController,
      required this.userAccessController,
      required this.stop,
      this.claimPrizeFailed = false,
      super.key});

  @override
  Widget build(BuildContext context) {
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
                    // if(gamificationController.userIsPlaying.value)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: Colors.black.withAlpha(20)),
                          child: claimPrizeFailed
                              ? const Icon(
                                  Icons.error_rounded,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )),
                    ),
                  ],
                ),
              ),
              Text(
                claimPrizeFailed
                    ? AppLocalizations.of(context)!.check_out_error
                    : AppLocalizations.of(context)!.check_out,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    userAccessController.userId?.then((value) {
                      final response =
                          gamificationController.checkOut(stop, value!);
                      onPressed?.call(response);
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.check_out_claim)),
            ],
          ),
        ));
  }
}
