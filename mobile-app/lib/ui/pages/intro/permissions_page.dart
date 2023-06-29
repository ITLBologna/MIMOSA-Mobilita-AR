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
import 'package:formatted_text/formatted_text.dart';
import 'package:mimosa/ui/library_widgets/future_builder_enhanced.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PermissionsPage extends StatefulWidget {
  final void Function() onNext;
  final Permission permission;
  final String deniedMessage;
  final String permanentlyDeniedMessage;
  final IconData iconData;

  const PermissionsPage({
    super.key,
    required this.onNext,
    required this.permission,
    required this.deniedMessage,
    required this.permanentlyDeniedMessage,
    required this.iconData
  });

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> with WidgetsBindingObserver {
  late Future<PermissionStatus> permissionsFuture;
  @override
  void initState() {
    permissionsFuture = widget.permission.request();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      permissionsFuture = widget.permission.request();
      permissionsFuture
          .then((value) {
            if (mounted) {
              setState(() {});
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {
            permissionsFuture = widget.permission.request();
          }),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column (
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80.0, bottom: 30),
                    child: Icon(widget.iconData, size: 150, color: Colors.black26,),
                  ),
                  FutureBuilderEnhanced(
                      future: permissionsFuture,
                      onDataLoaded: (status) {
                        if(status == PermissionStatus.granted) {
                            WidgetsBinding
                                .instance
                                .addPostFrameCallback((timeStamp) => widget.onNext());
                            return Text(AppLocalizations.of(context)!.launching);
                        }
                        else if(status == PermissionStatus.permanentlyDenied) {
                          WidgetsBinding.instance.addObserver(this);
                          return FormattedTextAndButton(
                            page: widget,
                            message: widget.permanentlyDeniedMessage,
                            getPermissionFuture: () => widget.permission.request(),
                            permissionNotGrantedAction: () {
                              openAppSettings();
                            },
                          );
                        }
                        else {
                          return FormattedTextAndButton(
                            page: widget,
                            message: widget.deniedMessage,
                            getPermissionFuture: () {
                              permissionsFuture = widget.permission.request();
                              return permissionsFuture;
                            },
                            permissionNotGrantedAction: () {
                              openAppSettings();
                            },
                          );
                        }
                      }
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormattedTextAndButton extends StatelessWidget {
  final Future<PermissionStatus> Function() getPermissionFuture;
  final void Function() permissionNotGrantedAction;
  final PermissionsPage page;
  final String message;

  const FormattedTextAndButton({
    super.key,
    required this.message,
    required this.getPermissionFuture,
    required this.permissionNotGrantedAction,
    required this.page
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormattedText(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: ElevatedButton(
              onPressed: () {
                getPermissionFuture()
                    .then((status) {
                      if(status == PermissionStatus.granted) {
                        WidgetsBinding
                            .instance
                            .addPostFrameCallback((timeStamp) => page.onNext());
                        return Text(AppLocalizations.of(context)!.launching);
                      }
                      else {
                        permissionNotGrantedAction();
                      }
                });
              },
              child: Text(AppLocalizations.of(context)!.settings)
          ),
        )
      ],
    );
  }

}
