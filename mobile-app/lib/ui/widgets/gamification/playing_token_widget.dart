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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/gamification_controller.dart';
import 'package:mimosa/ui/library_widgets/alert_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayingTokenWidget extends StatefulWidget {
  final bool tapEnabled;
  const PlayingTokenWidget({
    this.tapEnabled = true,
    super.key
  });

  @override
  State<PlayingTokenWidget> createState() => _PlayingTokenWidgetState();
}

class _PlayingTokenWidgetState extends State<PlayingTokenWidget> with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final GamificationController gamificationController;

  @override
  void initState() {
    gamificationController = Get.find<GamificationController>();

    animationController = AnimationController(
      vsync: this,
      upperBound: 2 * pi,
      duration: const Duration(seconds: 4)
    )..repeat();

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 0),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()..rotateY(animationController.value),
            alignment: Alignment.center,
            child: child
          );
        },
        child: TextButton(
          onPressed: () {
            showAlertDialogEx(
              context,
              type: DialogExType.okCancelDestructive,
              progressIndicatorTag: 'gamy_dialog',
              title: l.playing_title,
              message: '',
              cancelText: l.close,
              confirmText: l.cancel_check_in,
              confirmAction: gamificationController.cancelCheckIn,
              getBodyWidget: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.check_in_text, style: Theme.of(context).textTheme.titleSmall,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${gamificationController.checkedInStop?.name} (#${gamificationController.checkedInStop?.code})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Text(l.check_out_text, style: Theme.of(context).textTheme.titleSmall,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        gamificationController.otpLastStop == null
                          ? l.check_out_instructions
                          : '${gamificationController.otpLastStop!.stopName} (#${gamificationController.otpLastStop!.stopCode})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                );
              }
            );
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              color: Colors.white
            ),
            child: Image.asset('assets/images/trophy_512.png', scale: 20,),
          ),
        ),
      ),
    );
  }
}