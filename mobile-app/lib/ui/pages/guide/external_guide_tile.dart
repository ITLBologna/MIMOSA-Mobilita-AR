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

class ExternalGuideTile extends StatelessWidget {
  final Function? onCardTap;
  final String text;

  const ExternalGuideTile({Key? key, this.onCardTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () {
                  if (onCardTap != null) onCardTap!();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.question_mark,
                                size: 18, color: Colors.amber),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.circle_outlined,
                                size: 38,
                                color: Colors.amber,
                              ))
                        ],
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8)),
                      Expanded(
                        child: AutoSizeText(
                          text,
                          textAlign: TextAlign.start,
                          maxLines: 4,
                          softWrap: true,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 28,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
