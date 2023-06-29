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
import 'package:mimosa/ui/pages/guide/guide_page.dart';
import 'package:tuple/tuple.dart';

typedef TileCallback = Widget Function(BuildContext);

class GenericGuidePage extends StatelessWidget implements IGuidePage {
  final TileCallback? firstTile;
  final TileCallback? secondTile;
  final TileCallback? thirdTile;

  final Tuple3<int, int, int> weights;

  @override
  final bool requireInteractionBeforeNextPage;

  @override
  final bool showIfNotFirstTime;

  @override
  final String pageName;

  const GenericGuidePage({Key? key,
    this.firstTile,
    this.secondTile,
    this.thirdTile,
    this.requireInteractionBeforeNextPage = false,
    this.showIfNotFirstTime = true,
    this.pageName = '',
    this.weights = const Tuple3(5, 9, 10)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OverflowBox(
        child: Column(
          children: [
            Expanded(
                flex: weights.item1,
                child: firstTile != null
                    ? Container(child: firstTile!(context))
                    : Container()),
            Flexible(
                flex: weights.item2,
                child: secondTile != null ? secondTile!(context) : Container()),
            Expanded(
                flex: weights.item3,
                child: thirdTile != null
                    ? Container(child: thirdTile!(context))
                    : Container()),
          ],
        ),
      ),
    );
  }
}
