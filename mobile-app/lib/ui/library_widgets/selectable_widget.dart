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

class SelectableWidget extends StatefulWidget {
  final Widget child;
  final bool _isSelected;
  final void Function(bool isSelected) onSelected;
  const SelectableWidget({Key? key, required this.child, bool isSelected = false, required this.onSelected})
      : _isSelected = isSelected, super(key: key);

  @override
  State<SelectableWidget> createState() => _SelectableWidgetState();
}

class _SelectableWidgetState extends State<SelectableWidget> {
  late bool _isSelected;

  @override
  void initState() {
    _isSelected = widget._isSelected;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
        borderWidth: 0,
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        fillColor: Colors.transparent,
        splashColor: Colors.transparent,
        isSelected: [_isSelected],
        children: [widget.child],
        onPressed: (index) {
          setState(() {
            _isSelected = !_isSelected;
            widget.onSelected(_isSelected);
          });
        },
    );
  }
}