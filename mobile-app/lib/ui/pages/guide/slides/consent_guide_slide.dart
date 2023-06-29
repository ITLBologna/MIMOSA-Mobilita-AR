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
import 'package:mimosa/ui/library_widgets/checkbox_option.dart';
import 'package:mimosa/ui/library_widgets/checkbox_option_group.dart';
import 'package:mimosa/ui/pages/guide/guide_description_tile.dart';
import 'package:mimosa/ui/pages/guide/guide_icon_tile.dart';
import 'package:mimosa/ui/pages/guide/scrollable_guide_page.dart';
import 'package:mimosa/ui/pages/guide/slides/i_guide_slide.dart';

class ConsentGuideSlide extends IGuideSlide {
  final List<String>? selectedOptions;
  final Function(List<String>?) onConsentOptionSelected;

  ConsentGuideSlide(
      {required this.onConsentOptionSelected, this.selectedOptions});

  @override
  Widget page() => ScrollableGuidePage(
        pageName: 'consent',
        requireInteractionBeforeNextPage: true,
        firstTile: (context) => const GuideIconTile(
          image: Icon(Icons.privacy_tip_rounded, size: 92, color: Colors.teal),
        ),
        secondTile: (context) => GuideDescriptionTile(
          title: AppLocalizations.of(context)?.guide_consent_page_title ?? '',
          descriptionParagraphs: [
            AppLocalizations.of(context)?.guide_consent_page_description_1 ??
                '',
            '',
            AppLocalizations.of(context)?.guide_consent_page_description_2 ??
                '',
          ],
        ),
        thirdTile: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              CheckboxOptionGroup(
                  scrollable: false,
                  selectedOptions: selectedOptions,
                  onSelected: (selected) {
                    onConsentOptionSelected(selected);
                  },
                  options: (selected, onSelect) => [
                        CheckboxOption(
                          id: 'suggestions',
                          icon: Icons.lightbulb_rounded,
                          title: AppLocalizations.of(context)
                                  ?.guide_consent_page_suggestions_title ??
                              '',
                          message: AppLocalizations.of(context)
                                  ?.guide_consent_page_suggestions_description ??
                              '',
                          isSelected:
                              selected?.contains('suggestions') ?? false,
                          onSelect: onSelect,
                        ),
                        CheckboxOption(
                          id: 'gamification',
                          icon: Icons.emoji_events_rounded,
                          title: AppLocalizations.of(context)
                                  ?.guide_consent_page_gamification_title ??
                              '',
                          message: AppLocalizations.of(context)
                                  ?.guide_consent_page_gamification_description ??
                              '',
                          isSelected:
                              selected?.contains('gamification') ?? false,
                          onSelect: onSelect,
                        ),
                        CheckboxOption(
                          id: 'survey',
                          icon: Icons.poll_rounded,
                          title: AppLocalizations.of(context)
                                  ?.guide_consent_page_survey_title ??
                              '',
                          message: AppLocalizations.of(context)
                                  ?.guide_consent_page_survey_description ??
                              '',
                          isSelected: selected?.contains('survey') ?? false,
                          onSelect: onSelect,
                        )
                      ]),
            ],
          ),
        ),
      );
}
