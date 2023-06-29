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
import 'package:mimosa/business_logic/models/section.dart';

class ListViewWithSections<C, H> extends StatelessWidget {
  final List<Section<C, H>> sections;
  final Widget Function(BuildContext context, C sectionContent) buildWidget;
  final Widget Function(BuildContext context, H header)? buildHeader;
  const ListViewWithSections(this.sections, {Key? key, this.buildHeader, required this.buildWidget}) : super(key: key);

  // List<Widget> getSlivers (BuildContext context, String? searchFamilies) {
  //   final sectionsFiltered = searchFamilies == null
  //           ? sections
  //           : sections.where((s) => s.sectionHeader.toLowerCase().contains(searchFamilies.toLowerCase())).toList();
  //   if(sectionsFiltered.isEmpty) {
  //     return [];
  //   }
  //
  //   return sectionsFiltered
  //       .map((s) {
  //         return [
  //           SliverList(
  //             delegate: SliverChildListDelegate(
  //                 [
  //                   buildHeader != null
  //                       ? buildHeader!(context, s.sectionHeader)
  //                       : Text(s.sectionHeader.toString())
  //                 ]
  //             )
  //           ),
  //           SliverList(
  //             delegate: SliverChildBuilderDelegate(
  //                     (context, index) {
  //                   return buildWidget(context, s.sectionContent[index]);
  //                 },
  //                 childCount: s.sectionContent.length
  //             )
  //           )
  //         ];
  //       })
  //     .reduce((value, element) {
  //       value.addAll(element);
  //       return value;
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    if(sections.isEmpty) {
      return Container();
    }

    final List<Widget> slivers =
      sections
        .map((s) {
          return [
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    buildHeader != null
                        ? buildHeader!(context, s.sectionHeader)
                        : Text(s.sectionHeader.toString())
                  ]
              )
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return buildWidget(context, s.sectionContent[index]);
                  },
                  childCount: s.sectionContent.length
              )
            )
          ];
        })
        .reduce((value, element) {
          value.addAll(element);
          return value;
        });

    return CustomScrollView(
      slivers: slivers
    );
  }
}
class GridViewWithSections<C, H> extends StatelessWidget {
  final List<Section<C, H>> sections;
  final SliverGridDelegate sliverGridDelegate;
  final Widget Function(BuildContext context, C sectionContent) buildWidget;
  final Widget Function(BuildContext context, H header)? buildHeader;

  const GridViewWithSections(
    this.sections,
    {Key? key,
    this.buildHeader,
    required this.buildWidget,
    required this.sliverGridDelegate
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers =
    sections
      .map((s) {
        return [
          SliverList(
              delegate: SliverChildListDelegate(
                  [
                    buildHeader != null
                        ? buildHeader!(context, s.sectionHeader)
                        : Text(s.sectionHeader.toString())
                  ]
              )
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return buildWidget(context, s.sectionContent[index]);
                },
                childCount: s.sectionContent.length,
              ),
              gridDelegate: sliverGridDelegate
          ),
        ];
      })
      .reduce((value, element) {
        value.addAll(element);
        return value;
      });

    return CustomScrollView(
      slivers: slivers
    );
  }
}
