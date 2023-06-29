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
import 'package:mimosa/business_logic/models/apis/autocomplete_place.dart';

class AutocompletePlacesList extends StatefulWidget {
  final List<AutocompletePlace>? autocompletePlaces;
  final Function(AutocompletePlace autocompletePlace)? onClick;

  const AutocompletePlacesList({super.key, this.autocompletePlaces, this.onClick});

  @override
  State<AutocompletePlacesList> createState() => _AutocompletePlacesListState();
}

class _AutocompletePlacesListState extends State<AutocompletePlacesList> {

  @override
  Widget build(BuildContext context) {
    if (widget.autocompletePlaces == null) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 64), child: Text("Digita per cercare..."),),);
    } else if (widget.autocompletePlaces?.isEmpty == true) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 64), child: Text("Nessun risultato..."),),);
    } else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.autocompletePlaces!.length,
          itemBuilder: (context, index) {
            return Material(
                key: UniqueKey(),
                child: Ink(
                  decoration: const BoxDecoration(),
                  child: InkWell(
                    onTap: () async {
                      if (widget.onClick != null) {
                        widget.onClick!(widget.autocompletePlaces![index]);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.autocompletePlaces![index].name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          if (widget.autocompletePlaces![index].locality != null) ...[
                            Text(widget.autocompletePlaces![index].locality!,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15))
                          ]
                        ],
                      ),
                    ),
                  ),
                ));
          });
    }
  }
}