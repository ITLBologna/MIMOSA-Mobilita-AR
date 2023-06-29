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

class GuideDescriptionTile extends StatelessWidget {
  final String? title;
  final Color? titleColor;
  final List<String>? descriptionParagraphs;
  final bool scrollable;

  const GuideDescriptionTile(
      {Key? key,
      this.title,
      this.titleColor,
      this.descriptionParagraphs,
      this.scrollable = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title != null
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: AutoSizeText(
                  title!,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: titleColor ?? Colors.black),
                  textAlign: TextAlign.center,
                ))
            : Container(),
        (descriptionParagraphs?.length ?? 0) > 0
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: !scrollable
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    itemCount: descriptionParagraphs?.length,
                    itemBuilder: (_, i) {
                      return AutoSizeText(descriptionParagraphs?[i] ?? '',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center);
                    }))
            : Container(),
      ],
    );
  }
}
