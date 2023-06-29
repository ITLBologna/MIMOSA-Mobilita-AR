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
import 'package:mimosa/ui/library_widgets/radio_option.dart';

class RadioOptionGroup extends StatefulWidget {
  final String? selectedOption;
  final void Function(String?)? onSelected;
  final List<RadioOption> Function(String?, Function(String)) options;

  const RadioOptionGroup(
      {Key? key, required this.options, this.selectedOption, this.onSelected})
      : super(key: key);

  @override
  State<RadioOptionGroup> createState() => _RadioOptionGroupState();
}

class _RadioOptionGroupState extends State<RadioOptionGroup> {
  String? selectedOption;

  @override
  void initState() {
    selectedOption = widget.selectedOption;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<RadioOption> options = widget.options(selectedOption, (selected) {
      setState(() {
        selectedOption = selected;
        widget.onSelected?.call(selectedOption);
      });
    });

    return ListView.builder(
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (context, index) {
          double topPadding = index == 0 ? 8.0 : 0.0;
          double bottomPadding = index == options.length - 1 ? 0.0 : 8.0;
          return Padding(
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            child: options[index],
          );
        });
  }
}
