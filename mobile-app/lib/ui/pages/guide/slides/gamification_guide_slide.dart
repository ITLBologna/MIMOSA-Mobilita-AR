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
import 'package:mimosa/controllers/permissions_controller.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/pages/guide/external_guide_tile.dart';
import 'package:mimosa/ui/pages/guide/generic_guide_page.dart';
import 'package:mimosa/ui/pages/guide/guide_description_tile.dart';
import 'package:mimosa/ui/pages/guide/guide_icon_tile.dart';
import 'package:mimosa/ui/pages/guide/guide_permission_tile.dart';
import 'package:mimosa/ui/pages/guide/slides/i_guide_slide.dart';
import 'package:mimosa/ui/pages/web_guide/web_guide_arguments.dart';

class GamificationGuideSlide extends IGuideSlide {
  @override
  Widget page() => GenericGuidePage(
        pageName: 'activityRecognition',
        requireInteractionBeforeNextPage: true,
        firstTile: (context) => GuideIconTile(
          image: Icon(
            Icons.emoji_events,
            size: 92,
            color: Colors.red.withGreen(160).withRed(210),
          ),
        ),
        secondTile: (context) => GuideDescriptionTile(
          title:
              AppLocalizations.of(context)?.guide_gamification_page_title ?? '',
          descriptionParagraphs: [
            AppLocalizations.of(context)!.guide_gamification_page_description_1,
            '',
            AppLocalizations.of(context)!.guide_gamification_page_description_2,
            // '',
            // AppLocalizations.of(context)!.guide_gamification_page_description_3,
          ],
        ),
        thirdTile: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GuidePermissionTile(
              title: AppLocalizations.of(context)
                      ?.guide_activity_permission_title ??
                  '',
              description: AppLocalizations.of(context)
                      ?.guide_activity_permission_description ??
                  '',
              iconData: Icons.directions_bike_rounded,
              permission: MimosaPermission.activityRecognition,
            ),
            ExternalGuideTile(
              text: AppLocalizations.of(context)
                      ?.guide_gamification_help_description ??
                  '',
              onCardTap: () => Get.toNamed(webGuideRoute,
                  arguments: WebGuideArguments(GuidePage.gamification)),
            ),
          ],
        ),
      );
}
