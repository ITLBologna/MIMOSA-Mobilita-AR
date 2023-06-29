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
import 'package:get/get.dart';
import 'package:mimosa/controllers/agency_selection_controller.dart';
import 'package:mimosa/controllers/mimosa_search_controller.dart';
import 'package:mimosa/controllers/view_models/agency_vm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mimosa/ui/widgets/search/animated_search_widget.dart';

class RouteSearchWidget extends StatelessWidget {
  final List<AgencyVM> agencies;
  const RouteSearchWidget({
    this.agencies = const [],
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final items = agencies
        .map((a) => DropdownMenuItem(
            value: a.agency.id,
            child: Text(
              a.agency.name,
              style: a.isSelected
                  ? Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context).textTheme.headlineSmall,)
          ),
        )
        .toList();

    final agenciesController = Get.find<AgencySelectionController>();
    final searchRoutesUIController = Get.find<MimosaSearchController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 20, bottom: 5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
                isExpanded: true,
                items: items,
                value: agenciesController.getSelected()!.id,
                onChanged: (String? value) {
                  agenciesController.selectFromValue(value);
                }
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 15),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(AppLocalizations.of(context)!.bus_lines, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),),
              ),
              AnimatedSearchWidget(
                  searchDebounceInMilliseconds: 300,
                  searchFieldBackgroundColor: Colors.black26.withAlpha(20),
                  onChanged: (text) {
                    searchRoutesUIController.searchText.value = text;
                  }
              )
            ],
          ),
        ),
      ],
    );
  }

}