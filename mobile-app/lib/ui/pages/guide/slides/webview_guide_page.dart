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
import 'package:mimosa/ui/pages/guide/generic_guide_page.dart';
import 'package:mimosa/ui/pages/guide/guide_page.dart';

class WebViewGuidePage extends StatelessWidget implements IGuidePage {
  @override
  final String pageName;

  @override
  final bool requireInteractionBeforeNextPage;

  @override
  final bool showIfNotFirstTime;

  final TileCallback tile;

  const WebViewGuidePage(
      {super.key,
      required this.pageName,
      required this.requireInteractionBeforeNextPage,
      required this.showIfNotFirstTime,
      required this.tile});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: tile(context),
      ),
    );
  }
}
