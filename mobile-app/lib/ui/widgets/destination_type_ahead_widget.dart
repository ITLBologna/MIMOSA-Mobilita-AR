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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/models/apis/autocomplete_place.dart';
import 'package:ar_location_view/ar_position.dart';
import 'package:mimosa/business_logic/services/interfaces/i_autocomplete_place_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DestinationTypeAheadWidget extends StatefulWidget {
  final void Function(AutocompletePlace selectedPlace, ArPosition userPosition)
      onPlaceSelected;

  const DestinationTypeAheadWidget({
    super.key,
    required this.onPlaceSelected,
  });

  @override
  State<DestinationTypeAheadWidget> createState() =>
      _DestinationTypeAheadWidgetState();
}

class _DestinationTypeAheadWidgetState
    extends State<DestinationTypeAheadWidget> {
  AutocompletePlace? selectedPlace;
  String lastPattern = '';
  late final TextEditingController textController;
  late final ILocationService _locationService;
  final autocompletePlacesService =
      serviceLocator.get<IAutocompletePlaceService>();

  @override
  void initState() {
    textController = TextEditingController();
    _locationService = serviceLocator.get<ILocationService>();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          textController.text = selectedPlace?.description ?? '';
        } else {
          textController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textController.text.length,
          );
        }
      },
      child: TypeAheadFormField(
        autoFlipDirection: true,
        minCharsForSuggestions: 2,
        textFieldConfiguration: TextFieldConfiguration(
          controller: textController,
          textInputAction: TextInputAction.done,
          onSubmitted: (text) {},
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black)
                  .copyWith(fontSize: 16),
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              hintText: AppLocalizations.of(context)!.digit_your_destination,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ),
        suggestionsCallback: (pattern) {
          lastPattern = pattern;
          return _locationService
              .getLastPosition()
              .then((p) => autocompletePlacesService.getAutocompletePlaces(
                  input: pattern, location: LatLng(p.latitude, p.longitude)))
              .fold((failures) {
            return <AutocompletePlace>[];
          }, (val) => val);
        },
        itemBuilder: (BuildContext context, AutocompletePlace suggestion) {
          return ListTile(
            minLeadingWidth: 5,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            dense: true,
            leading: const Icon(Icons.place),
            title: Text(
              suggestion.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: suggestion.locality != null && suggestion.locality != '' ? Text([suggestion.locality, suggestion.provinceShort, suggestion.region].where((element) => element != null && element != '').join(', ')) : null,
          );
        },
        onSuggestionSelected: (AutocompletePlace suggestion) {
          debugPrint("ON SELECTED");
          MatomoTracker.instance.trackSearch(searchKeyword: lastPattern);
          selectedPlace = suggestion;
          textController.text = suggestion.description;
          _locationService
              .getLastPosition()
              .then((value) => widget.onPlaceSelected(suggestion, value));
        },
      ),
    );
  }
}
