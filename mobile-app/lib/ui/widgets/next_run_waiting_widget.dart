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
import 'package:shimmer/shimmer.dart';

class NextRunWaitingWidget extends StatelessWidget {
  final double? size;
  final double padding;
  final bool fullscreen;
  const NextRunWaitingWidget({
    this.size,
    this.fullscreen = false,
    this.padding = 8.0,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final sz = size ?? 100;
    final squareContainerSize = min((sz - (padding * 2)) / 3, 50.0);
    final lineContainerSize = sz - squareContainerSize - (padding * 3);

    var h = squareContainerSize + (padding * 2);

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100!,
      enabled: true,
      child: Container(
        width: sz,
        height: h,
        padding: EdgeInsets.all(padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: squareContainerSize,
              height: squareContainerSize,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.only(left: padding),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: lineContainerSize,
                  height: squareContainerSize / 3,
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(top: squareContainerSize / 3),
                  child: Container(
                    width: lineContainerSize / 2,
                    height: squareContainerSize / 3,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}