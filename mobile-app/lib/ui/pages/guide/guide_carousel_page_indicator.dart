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

class GuideCarouselPageIndicator extends StatefulWidget {
  final int totalPages;
  final int currentPageIndex;

  final Color currentIndicatorColor;
  final Color indicatorColor;

  const GuideCarouselPageIndicator(
      {Key? key,
      required this.totalPages,
      this.currentPageIndex = 0,
      this.currentIndicatorColor = Colors.black,
      this.indicatorColor = Colors.grey})
      : super(key: key);

  @override
  State<GuideCarouselPageIndicator> createState() =>
      _GuideCarouselPageIndicatorState();
}

class _GuideCarouselPageIndicatorState
    extends State<GuideCarouselPageIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight,
      child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.totalPages,
            separatorBuilder: (context, index) {
              return const Padding(padding: EdgeInsets.symmetric(horizontal: 2));
            },
            itemBuilder: (context, index) {
              return Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == widget.currentPageIndex
                          ? widget.currentIndicatorColor
                          : widget.indicatorColor),
                  width: 8,
                  height: 8);
            }),
    );
  }
}
