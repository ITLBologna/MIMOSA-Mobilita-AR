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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/ui/library_widgets/error_widget.dart';

class ControllerDrivenWidget<T extends BaseController, D, RD> extends StatelessWidget {
  final T controller;
  final RD? requestData;
  final Widget Function(D data) getBody;
  final Color? backgroundColor;
  final Widget? errorWidget;
  final bool useCache;
  final String? controllerTag;
  final Widget? progressIndicator;
  final bool enablePullToRefresh;

  const ControllerDrivenWidget({
    Key? key,
    required this.controller,
    required this.getBody,
    this.errorWidget,
    this.requestData,
    this.useCache = true,
    this.enablePullToRefresh = true,
    this.controllerTag,
    this.progressIndicator,
    this.backgroundColor}) : super(key: key);

  bool isErrorOfType(Fail fail, Type t) =>
      fail.fold((err) => err.runtimeType == t, (exc) => false);  

  @override Widget build(BuildContext context) {    
    if(!controller.uiData.isValid)
    {
      controller.manageRequest(requestData, useCache: useCache);
    }
    
    return GetBuilder<T>(
            tag: controllerTag,
            builder: (_) =>
              controller
              .uiData
              .fold(
                (failures) {                  
                  if(isErrorOfType(failures.first, StateError))
                  {
                    return progressIndicator ?? const Center(child: CircularProgressIndicator());
                  }
                  else
                  {
                    return ErrorMessageWidget(
                        fails: failures,
                        buildChildErrorWidget:
                            (message) {
                              final child = errorWidget ?? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Center(child: Text('Richiesta dati in errore: $message')),
                                  ),
                                  Expanded(child: Container())
                                ],
                              );

                              if(enablePullToRefresh) {
                                return RefreshIndicator(
                                  child: CustomScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      slivers: [
                                        SliverFillRemaining(
                                          hasScrollBody: false,
                                          child: child
                                        ),
                                      ]
                                  ),
                                  onRefresh: () => controller.manageRequest(requestData, useCache: false),
                                );
                              }
                              else {
                                return child;
                              }
                              // Loader.hide();
                            }
                        );
                  }
                }, 
                (data) {
                  if(!controller.executing) {
                    // Loader.hide();
                    return Container(color: backgroundColor, child: getBody(data));
                  }
                  return const Center(child: CircularProgressIndicator());
              })
            );

  }
}