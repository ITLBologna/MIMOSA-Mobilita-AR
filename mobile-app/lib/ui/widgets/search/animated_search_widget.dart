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
import 'package:get/get.dart';
import 'package:mimosa/ui/widgets/animated_variable_size_widget.dart';
import 'package:mimosa/ui/widgets/search/custom_cupertino_search_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnimatedSearchWidget extends StatefulWidget {
  final String searchPlaceholder;
  final void Function(String value) onChanged;
  final Color? searchFieldBackgroundColor;
  final int searchDebounceInMilliseconds;
  final EdgeInsetsGeometry searchWidgetPadding;

  const AnimatedSearchWidget({
    super.key,
    this.searchPlaceholder = '',
    required this.onChanged,
    this.searchFieldBackgroundColor,
    this.searchDebounceInMilliseconds = 300,
    this.searchWidgetPadding = const EdgeInsets.symmetric(horizontal: 10.0)
  });

  @override
  State<AnimatedSearchWidget> createState() => _AnimatedSearchWidgetState();
}

class _AnimatedSearchWidgetState extends State<AnimatedSearchWidget> {
  final focusController = Get.put(FocusController());
  late TextEditingController searchTextController;

  @override @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cupertinoText = Expanded(
        child: Padding(
            padding: widget.searchWidgetPadding,
            child: CustomCupertinoSearchWidget(
              onChanged: widget.onChanged,
              searchPlaceholder: widget.searchPlaceholder,
              focusController: focusController,
              controller: searchTextController,
              debounceInMilliseconds: widget.searchDebounceInMilliseconds,
              backgroundColor: widget.searchFieldBackgroundColor,
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
                    widget.onChanged('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10.0, right: 10),
                    child: Text(AppLocalizations.of(context)!.cancel, style: Theme.of(context).textTheme.bodyMedium),
                  )
              ),
            )
        );
      }

      focusController.cancelExpanded.value = focusController.focusState.value == FocusState.focused;

      return Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: rowChildren,
        ),
      );
    });
  }
}