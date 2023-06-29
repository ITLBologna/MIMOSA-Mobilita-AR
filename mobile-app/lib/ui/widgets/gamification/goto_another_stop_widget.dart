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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/gamification_controller.dart';

class GotoAnotherStopWidget extends StatelessWidget {
  const GotoAnotherStopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GamificationController>();
    final text = gc.otpLastStop == null
                ? AppLocalizations.of(context)!.go_to_another_stop_to_checkout
                : AppLocalizations.of(context)!.go_to_otp_end_stop_to_checkout(gc.otpLastStop!.stopCode, gc.otpLastStop!.stopName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
      child: Center(
          child: Column(
            children: [
              Icon(Icons.info, color: Theme.of(context).primaryColor, size: 30,),
              Text(
                text,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          )
      ),
    );
  }
}
