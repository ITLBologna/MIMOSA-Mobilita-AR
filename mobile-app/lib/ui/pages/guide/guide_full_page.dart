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

typedef FullPageCallback = Widget Function(BuildContext);

class GuideFullPage extends StatefulWidget implements IGuidePage {
  final FullPageCallback content;

  const GuideFullPage(
      {Key? key,
      required this.content,
      this.requireInteractionBeforeNextPage = false,
      this.showIfNotFirstTime = true,
      this.pageName = ''})
      : super(key: key);

  @override
  State<GuideFullPage> createState() => _GuideFullPageState();

  @override
  final bool requireInteractionBeforeNextPage;

  @override
  final bool showIfNotFirstTime;

  @override
  final String pageName;
}

class _GuideFullPageState extends State<GuideFullPage> {
  @override
  Widget build(BuildContext context) {
    return widget.content(context);
  }
}
