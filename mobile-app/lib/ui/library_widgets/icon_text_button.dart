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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final double iconSize;
  final IconData iconData;
  final bool isPrimary;
  final String text;
  final bool small;
  final void Function() onPressed;

  const IconTextButton({
    Key? key,
    required this.iconData,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.iconSize = 22
  }) : small = false, super(key: key);

  const IconTextButton.small({
    Key? key,
    required this.iconData,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.iconSize = 15
  }) : small = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: isPrimary ? null : TextButton.styleFrom(foregroundColor: Theme.of(context).textTheme.bodyLarge?.color),
        child: Row(
          children: [
            Icon(iconData, size: iconSize,),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: AutoSizeText(text, style: TextStyle(fontSize: small ? 16 : null),),
            )
          ],
        )
    );
  }

}
