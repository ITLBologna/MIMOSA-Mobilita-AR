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
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mimosa/ui/widgets/animated_variable_size_widget.dart';
import 'package:mimosa/ui/widgets/search/custom_cupertino_search_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double preferredHeight;

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  const BottomAppBarWidget({Key? key, required this.child, required this.preferredHeight}) : super(key: key);

  @override Widget build(BuildContext context) {
    return child;
  }
}

class SliverSearchAppBar extends StatefulWidget {
  final Widget title;
  final String searchPlaceholder;
  final void Function(String value)? onChanged;
  final bool showSearchBar;
  final Color? backgroundColor;
  final Color? searchWidgetBackgroundColor;
  final double expandedHeight;
  final double searchBarHeight;
  final int searchDebounceInMilliseconds;
  final EdgeInsetsGeometry searchWidgetPadding;

  const SliverSearchAppBar(
      this.title,
      {Key? key,
        this.onChanged,
        required this.searchPlaceholder,
        this.backgroundColor,
        this.showSearchBar = true,
        this.searchBarHeight = 70,
        this.expandedHeight = 120,
        this.searchDebounceInMilliseconds = 200,
        this.searchWidgetBackgroundColor,
        this.searchWidgetPadding = const EdgeInsets.only(left: 20, right: 20, bottom: 15)
      }) : super(key: key);

  @override
  State<SliverSearchAppBar> createState() => _SliverSearchAppBarState();
}

class _SliverSearchAppBarState extends State<SliverSearchAppBar> {
  final focusController = Get.put(FocusController());

  late TextEditingController searchTextController;
  late ScrollController filterListScrollController;

  @override @override
  void initState() {
    searchTextController = TextEditingController();
    filterListScrollController = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    List<Widget> actions = [];

    return SliverAppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        expandedHeight: widget.expandedHeight,
        floating: true,
        pinned: true,
        snap: true,
        actions: actions,
        // centerTitle: false,
        backgroundColor: widget.backgroundColor ?? Theme.of(context).primaryColor,
        title: widget.title,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        titleSpacing: -5,
        bottom: BottomAppBarWidget(
            preferredHeight: widget.searchBarHeight,
            child: Obx(() {
              final cupertinoText = Expanded(
                child: Padding(
                    padding: widget.searchWidgetPadding,
                    child: CustomCupertinoSearchWidget(
                      onChanged: widget.onChanged,
                      searchPlaceholder: widget.searchPlaceholder,
                      focusController: focusController,
                      controller: searchTextController,
                      debounceInMilliseconds: widget.searchDebounceInMilliseconds,
                      backgroundColor: widget.searchWidgetBackgroundColor,
                    )
                ),
              );

              List<Widget> rowChildren = [cupertinoText];

              if(focusController.focusState.value != FocusState.none)
              {
                rowChildren.add(
                    AnimatedVariableSizeWidget(
                      expandedObs: focusController.cancelExpanded,
                      axis: Axis.horizontal,
                      child: TextButton(
                          onPressed: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus &&
                                currentFocus.focusedChild != null) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }

                            focusController.focusState.value = FocusState.unfocused;
                            searchTextController.clear();
                            if(widget.onChanged != null)
                            {
                              widget.onChanged!('');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 15.0, right: 10),
                            child: Text(AppLocalizations.of(context)!.cancel, style: Theme.of(context).textTheme.bodyMedium),
                          )
                      ),
                    )
                );
              }

              focusController.cancelExpanded.value = focusController.focusState.value == FocusState.focused;

              List<Widget> columnChildren = [];
              if(widget.showSearchBar) {
                columnChildren.add(Row(children: rowChildren));
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: columnChildren,
              );
            })
        )
    );
  }
}