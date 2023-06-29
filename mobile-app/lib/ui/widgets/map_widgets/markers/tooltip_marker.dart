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
import 'package:mimosa/ui/contants/colors_constants.dart';

class TooltipMarker extends StatefulWidget {
  final String stopName;
  final Widget icon;
  final Color? color;
  final Color? textColor;

  const TooltipMarker({
    required this.stopName,
    required this.icon,
    this.textColor,
    this.color,
    super.key});

  @override
  TooltipMarkerState createState() => TooltipMarkerState();
}

class TooltipMarkerState extends State<TooltipMarker> {
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final dynamic tooltip = key.currentState;
        tooltip.ensureTooltipVisible();
      },
      child: Tooltip(
        key: key,
        message: widget.stopName,
        textStyle: TextStyle(color: widget.textColor ?? mapTooltipTextColor),
        preferBelow: false,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: widget.color ?? mapTooltipColor
        ),
        child: Container(
          child: widget.icon,
        ),
      ),
    );
  }
}