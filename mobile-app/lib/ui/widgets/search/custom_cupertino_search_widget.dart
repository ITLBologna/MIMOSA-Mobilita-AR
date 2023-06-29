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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

enum FocusState {
  none,
  focused,
  unfocused
}

class FocusController extends GetxController {
  final focusState = FocusState.none.obs;
  final cancelExpanded = false.obs;
}

class SearchFieldController extends GetxController {
  bool _isClearTextVisible = false;
  bool get isClearTextVisible => _isClearTextVisible;
  set isClearTextVisible(bool value) {
    if(_isClearTextVisible != value)
    {
      _isClearTextVisible = value;
      update();
    }
  }

  void toggleClearTextButtonVisibility()
  {
    _isClearTextVisible = !_isClearTextVisible;
    update();
  }
}


class CustomCupertinoSearchWidget extends StatefulWidget {
  final void Function(String value)? onChanged;
  final String searchPlaceholder;
  final FocusController? focusController;
  final TextEditingController? controller;
  final int debounceInMilliseconds;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final String? textControllerTag;
  final Color searchIconColor;

  const CustomCupertinoSearchWidget(
      {Key? key,
        this.onChanged,
        this.controller,
        this.focusController,
        this.textControllerTag,
        this.debounceInMilliseconds = 350,
        this.borderRadius = 10,
        this.backgroundColor = Colors.white,
        this.textColor,
        this.searchIconColor = Colors.black26,
        required this.searchPlaceholder
      }) : super(key: key);

  @override
  State<CustomCupertinoSearchWidget> createState() => _CustomCupertinoSearchWidgetState();
}

class _CustomCupertinoSearchWidgetState extends State<CustomCupertinoSearchWidget> {
  final searchOnChange = BehaviorSubject<String>();
  late final FocusController focusController;
  late final TextEditingController textController;
  late final SearchFieldController searchFieldController;
  @override
  void initState() {
    textController = widget.controller ?? TextEditingController();
    Get.put(textController, tag: widget.textControllerTag);
    searchFieldController = Get.put(SearchFieldController());
    focusController = widget.focusController ?? Get.put(FocusController());

    searchOnChange.debounceTime(Duration(milliseconds: widget.debounceInMilliseconds)).listen((queryString) {
      if(widget.onChanged != null)
      {
        widget.onChanged!(queryString);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // Se il controller non ci arriva dall'esterno, eseguiamo la dispose
    Get.delete<TextEditingController>(tag: widget.textControllerTag);
    if(widget.controller == null) {
      textController.dispose();
    }
    searchOnChange.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchFieldController>(
        builder: (controller) =>
            FocusScope(
                child: Focus(
                    onFocusChange: (focus) {
                      focusController
                          .focusState
                          .value = focus ? FocusState.focused : FocusState.unfocused;
                    },
                    child: CupertinoTextField(
                        controller: textController,
                        autocorrect: false,
                        style: TextStyle(color: widget.textColor ?? Colors.grey[800]),
                        cursorColor: widget.textColor ?? Colors.grey[800],
                        padding: const EdgeInsets.all(8),
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Icon(Icons.search, color: widget.searchIconColor,),
                        ),
                        suffix: searchFieldController.isClearTextVisible
                            ? GestureDetector(
                          onTap: () {
                            textController.clear();
                            if(widget.onChanged != null)
                            {
                              widget.onChanged!('');
                            }
                            searchFieldController.toggleClearTextButtonVisibility();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(
                              CupertinoIcons.clear_thick_circled,
                              size: 18.0,
                              color: widget.searchIconColor,
                            ),
                          ),
                        )
                            : null,
                        decoration:
                        BoxDecoration(
                            color: widget.backgroundColor,
                            borderRadius: BorderRadius.circular(widget.borderRadius)
                        ),
                        textInputAction: TextInputAction.search,
                        placeholder: widget.searchPlaceholder,
                        placeholderStyle: TextStyle(fontWeight: FontWeight.w400, color: widget.searchIconColor),
                        onChanged: (value) {
                          searchOnChange.add(value);
                          searchFieldController.isClearTextVisible = value.isNotEmpty;
                        }
                    )
                )
            )
    );
  }
}