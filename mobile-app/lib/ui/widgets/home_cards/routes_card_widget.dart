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

@immutable
class RoutesCardWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const RoutesCardWidget({
    super.key,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Stack(
        children: [
          Image.asset('assets/images/mappa_autobus_bo.jpg'),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: TextButton(
                onPressed: onPressed,
                child: const Text('')
            ),
          ),
          Positioned(
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(AppLocalizations.of(context)!.go_to_bus_lines)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
