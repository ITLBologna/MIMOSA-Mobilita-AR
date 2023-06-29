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
import 'package:mimosa/business_logic/services/error_handler_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_error_handler.dart';

class FutureBuilderEnhanced<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T? data) onDataLoaded;
  final Widget Function(Object? error)? onError;
  final Widget? progressIndicator;
  final double? size;
  final IErrorHandler? errorHandler;

  const FutureBuilderEnhanced({Key? key,
    required this.future,
    required this.onDataLoaded,
    this.onError,
    this.progressIndicator,
    this.size = 48,
    this.errorHandler
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return onDataLoaded(snapshot.data);
          }
          else if(snapshot.hasError) {
            if(onError != null) {
              return onError!(snapshot.error);
            }

            final eh = errorHandler ?? ErrorHandlerService();
            final theme = Theme.of(context);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ops! Si è verificato un errore.', style: theme.textTheme.headlineSmall?.copyWith(color: theme.errorColor),),
                Text(eh.handleError(snapshot.error!))
              ],
            );
          }
          else {
            return progressIndicator ?? Container(
              width: size,
              height: size,
              color: context.theme.colorScheme.background,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2,)
              ),
            );
          }
        }
    );
  }
}