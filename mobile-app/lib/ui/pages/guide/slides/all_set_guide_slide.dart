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
import 'package:mimosa/ui/pages/guide/guide_full_page.dart';
import 'package:mimosa/ui/pages/guide/slides/i_guide_slide.dart';

class AllSetGuideSlide extends IGuideSlide {
  @override
  Widget page() => GuideFullPage(
      showIfNotFirstTime: false,
      requireInteractionBeforeNextPage: true,
      content: (context) {
        return Container(
          color: context.theme.primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 92),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              Text(AppLocalizations.of(context)?.guide_last_page_title ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white)),
            ],
          ),
        );
      });
}
