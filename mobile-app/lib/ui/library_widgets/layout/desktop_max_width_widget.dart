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

import 'dart:io';

import 'package:flutter/cupertino.dart';

class DesktopMaxWidthWidget extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const DesktopMaxWidthWidget({Key? key, required this.child, required this.maxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS || Platform.isAndroid)
        ? child
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          );
  }
}
