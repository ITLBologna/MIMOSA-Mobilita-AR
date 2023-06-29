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

class CheckoutPulsingCupWidget extends StatefulWidget {
  final VoidCallback onAnimationEnded;
  final int collectedPoints;

  const CheckoutPulsingCupWidget({
    required this.onAnimationEnded,
    required this.collectedPoints,
    super.key
  });

  @override
  State<CheckoutPulsingCupWidget> createState() => _CheckoutPulsingCupWidgetState();
}

class _CheckoutPulsingCupWidgetState extends State<CheckoutPulsingCupWidget> with TickerProviderStateMixin {
  late AnimationController motionController;
  late Animation motionAnimation;
  double size = 20;

  @override
  void initState() {
    super.initState();

    motionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      lowerBound: 0.5,
    );

    motionAnimation = CurvedAnimation(
      parent: motionController,
      curve: Curves.ease,
    );

    play();
  }

  void play() {
    motionController.forward();
    motionController.addStatusListener((status) {
      setState(() {
        if (status == AnimationStatus.completed) {
          motionController.reverse();
        }
        else if (status == AnimationStatus.dismissed) {
          widget.onAnimationEnded();
        }
      });
    });

    motionController.addListener(() {
      setState(() {
        size = motionController.value * 100;
      });
    });
  }

  @override
  void dispose() {
    motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/images/trophy_512.png', width: size,),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.congratulations),
                    Text(AppLocalizations.of(context)!.congratulations_points(widget.collectedPoints)),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}