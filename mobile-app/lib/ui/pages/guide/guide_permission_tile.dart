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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/permissions_controller.dart';
import 'package:permission_handler/permission_handler.dart';


class GuidePermissionTile extends StatefulWidget {
  final String description;
  final String title;
  final IconData iconData;
  final MimosaPermission permission;

  const GuidePermissionTile({Key? key,
    required this.description,
    required this.title,
    required this.iconData,
    required this.permission})
      : super(key: key);

  @override
  State<GuidePermissionTile> createState() => _GuidePermissionTileState();
}

class _GuidePermissionTileState extends State<GuidePermissionTile>
    with WidgetsBindingObserver {
  Stream<PermissionStatus>? permissionStatus;
  PermissionStatus currentPermissionStatus = PermissionStatus.denied;
  PermissionsController permissionsController = Get.find();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionsController.updateMimosaPermissionStatus();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      permissionsController.updateMimosaPermissionStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    permissionStatus =
    permissionsController.mimosaPermissionStatus.map((event) {
      switch (widget.permission) {
        case MimosaPermission.location:
          return event.locationPermissionStatus;
        case MimosaPermission.camera:
          return event.cameraPermissionStatus;
        case MimosaPermission.activityRecognition:
          return event.activityRecognitionPermissionStatus;
        case MimosaPermission.notification:
          return event.notificationPermissionStatus;
      }
    })
      ..listen((event) {
        currentPermissionStatus = event;
      });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.theme.primaryColor.withOpacity(0.2)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(widget.iconData,
                            size: 24, color: context.theme.primaryColor),
                      )),
                ),
                Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w800),
                    ))
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                switch (widget.permission) {
                  case MimosaPermission.location:
                    switch (currentPermissionStatus) {
                      case PermissionStatus.denied:
                        bool ssrr = await Permission.location
                            .shouldShowRequestRationale;
                        if (ssrr) {
                          Permission.location.request().then((value) {
                            if (value == PermissionStatus.denied) {
                              permissionsController
                                  .locationPermanentlyDeniedCounter++;
                            } else
                            if (value == PermissionStatus.permanentlyDenied) {
                              permissionsController
                                  .locationPermanentlyDeniedCounter += 2;
                            }
                            permissionsController
                                .updateMimosaPermissionStatus();
                          });
                        } else {
                          Permission.location.request().then((value) {
                            if (value == PermissionStatus.denied) {
                              permissionsController
                                  .locationPermanentlyDeniedCounter++;
                            } else
                            if (value == PermissionStatus.permanentlyDenied) {
                              permissionsController
                                  .locationPermanentlyDeniedCounter += 2;
                            }
                            permissionsController
                                .updateMimosaPermissionStatus();
                          });
                        }

                        break;
                      case PermissionStatus.permanentlyDenied:
                        openAppSettings();
                        break;
                      default:
                        break;
                    }
                    break;
                  case MimosaPermission.camera:
                    switch (currentPermissionStatus) {
                      case PermissionStatus.denied:
                        Permission.camera.request().then((value) {
                          permissionsController.updateMimosaPermissionStatus();
                        });
                        break;
                      case PermissionStatus.permanentlyDenied:
                        openAppSettings();
                        break;
                      default:
                        break;
                    }
                    break;
                  case MimosaPermission.activityRecognition:
                    switch (currentPermissionStatus) {
                      case PermissionStatus.denied:
                        if (Platform.isAndroid) {
                          Permission.activityRecognition.request().then((
                              value) {
                            permissionsController
                                .updateMimosaPermissionStatus();
                          });
                        } else if (Platform.isIOS) {
                          Permission.sensors.request().then((value) {
                            permissionsController
                                .updateMimosaPermissionStatus();
                          });
                        }
                        break;
                      case PermissionStatus.permanentlyDenied:
                        openAppSettings();
                        break;
                      default:
                        break;
                    }
                    break;
                  case MimosaPermission.notification:
                    switch (currentPermissionStatus) {
                      case PermissionStatus.denied:
                        Permission.notification.request().then((value) {
                          permissionsController.updateMimosaPermissionStatus();
                        });
                        break;
                      case PermissionStatus.permanentlyDenied:
                        openAppSettings();
                        break;
                      default:
                        break;
                    }
                    break;
                }
              },
              borderRadius: BorderRadius.circular(8.0),
              splashColor: Colors.grey.withOpacity(0.5),
              highlightColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.description,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 8.0, top: 4, bottom: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            StreamBuilder(
                                stream: permissionsController.mps(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return PermissionActionButton(
                                        permissionStatus: _getPermissionStatus(
                                            snapshot.data, widget.permission));
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                })
                          ]),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PermissionStatus _getPermissionStatus(
      MimosaPermissionStatus? mimosaPermissionStatus,
      MimosaPermission mimosaPermission) {
    switch (mimosaPermission) {
      case MimosaPermission.location:
        return mimosaPermissionStatus?.locationPermissionStatus ??
            PermissionStatus.denied;
      case MimosaPermission.camera:
        return mimosaPermissionStatus?.cameraPermissionStatus ??
            PermissionStatus.denied;
      case MimosaPermission.activityRecognition:
        return mimosaPermissionStatus?.activityRecognitionPermissionStatus ??
            PermissionStatus.denied;
      case MimosaPermission.notification:
        return mimosaPermissionStatus?.notificationPermissionStatus ??
            PermissionStatus.denied;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class PermissionActionButton extends StatefulWidget {
  final PermissionStatus? permissionStatus;

  const PermissionActionButton({Key? key, this.permissionStatus})
      : super(key: key);

  @override
  State<PermissionActionButton> createState() => _PermissionActionButtonState();
}

class _PermissionActionButtonState extends State<PermissionActionButton> {
  String buttonText = '';

  @override
  Widget build(BuildContext context) {
    switch (widget.permissionStatus) {
      case PermissionStatus.granted:
        buttonText =
            AppLocalizations.of(context)!.guide_permission_allowed_text;
        break;
      case PermissionStatus.denied:
        buttonText = AppLocalizations.of(context)!.guide_permission_allow_text;
        break;
      case PermissionStatus.restricted:
        buttonText = AppLocalizations.of(context)!.guide_permission_allow_text;
        break;
      case PermissionStatus.limited:
        buttonText =
            AppLocalizations.of(context)!.guide_permission_allowed_text;
        break;
      case PermissionStatus.permanentlyDenied:
        buttonText =
            AppLocalizations.of(context)!.guide_permission_settings_text;
        break;
      case null:
        buttonText = '';
        break;
    };

    var actionWidgets = <Widget>[
      Text(
        buttonText,
        style: TextStyle(
            color: context.theme.primaryColor, fontWeight: FontWeight.w600),
      ),
      Icon(Icons.chevron_right_rounded,
          size: 18, color: context.theme.primaryColor)
    ];

    var grantedWidgets = <Widget>[
      const Padding(
        padding: EdgeInsets.only(right: 4.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.circle, size: 18, color: Colors.green),
            Icon(Icons.check_rounded, size: 12, color: Colors.white),
          ],
        ),
      ),
      Text(
        buttonText,
        style:
        const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
      ),
    ];

    return Flex(
      direction: Axis.horizontal,
      children: [
        if (widget.permissionStatus != PermissionStatus.granted &&
            widget.permissionStatus != PermissionStatus.limited)
          ...actionWidgets,
        if (widget.permissionStatus == PermissionStatus.granted ||
            widget.permissionStatus == PermissionStatus.limited)
          ...grantedWidgets
      ],
    );
  }
}
