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
import 'package:mimosa/ui/library_widgets/checkbox_option.dart';

class CheckboxOptionGroup extends StatefulWidget {
  final List<String>? selectedOptions;
  final void Function(List<String>?)? onSelected;
  final List<CheckboxOption> Function(List<String>?, Function(String)) options;
  final bool scrollable;

  const CheckboxOptionGroup(
      {Key? key,
      required this.options,
      this.selectedOptions,
      this.onSelected,
      this.scrollable = true})
      : super(key: key);

  @override
  State<CheckboxOptionGroup> createState() => _CheckboxOptionGroupState();
}

class _CheckboxOptionGroupState extends State<CheckboxOptionGroup> {
  List<String>? selectedOptions;

  @override
  void initState() {
    selectedOptions = widget.selectedOptions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CheckboxOption> options = widget.options(selectedOptions, (selected) {
      setState(() {
        if (selectedOptions == null) {
          selectedOptions = [selected];
        } else if (selectedOptions!.contains(selected)) {
          selectedOptions!.remove(selected);
        } else {
          selectedOptions!.add(selected);
        }
        widget.onSelected?.call(selectedOptions);
      });
    });

    return ListView.builder(
        shrinkWrap: true,
        itemCount: options.length,
        physics:
            !widget.scrollable ? const NeverScrollableScrollPhysics() : null,
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
