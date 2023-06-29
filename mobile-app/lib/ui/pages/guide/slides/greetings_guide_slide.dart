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
import 'package:mimosa/ui/pages/guide/generic_guide_page.dart';
import 'package:mimosa/ui/pages/guide/guide_description_tile.dart';
import 'package:mimosa/ui/pages/guide/guide_icon_tile.dart';
import 'package:mimosa/ui/pages/guide/slides/i_guide_slide.dart';

class GreetingsGuideSlide extends IGuideSlide {
  @override
  Widget page() => GenericGuidePage(
        firstTile: (context) => GuideIconTile(
            image: SizedBox(
                width: 92,
                height: 92,
                child: Image.asset('assets/images/icon.png'))),
        secondTile: (context) => GuideDescriptionTile(
          title: AppLocalizations.of(context)?.guide_welcome_page_title ?? '',
          descriptionParagraphs: [
            AppLocalizations.of(context)?.guide_welcome_page_description ?? ''
          ],
        ),
      );
}
