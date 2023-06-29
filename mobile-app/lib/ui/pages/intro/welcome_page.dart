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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomePage extends StatefulWidget {
  final void Function() onNext;
  final void Function(int page) jumpTo;
  const WelcomePage({super.key, required this.onNext, required this.jumpTo});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _locationService = serviceLocator.get<ILocationService>();
  late Future<MimosaLocationPermissionStatus> locationAlwaysIsGranted;

  void recCheckPermission(List<Permission> permissions, {int index = 0}) {
    permissions[index]
      .request()
      .then((value) {
        if(value == PermissionStatus.granted) {
          if(index == permissions.length - 1) {
            WidgetsBinding
                .instance
                .addPostFrameCallback((timeStamp) => Get.offAndToNamed(homeRoute));
          }
          else {
            recCheckPermission(permissions, index: ++index);
          }
        }
        else {
          widget.jumpTo(index + 2);
        }
      });
  }

  @override
  void initState() {
    final otherPermissions = [
      Permission.camera,
      Permission.activityRecognition
    ];

    locationAlwaysIsGranted = _locationService.checkLocationPermissions();

    Future.delayed(const Duration(seconds: 1))
      .then((_) =>
        locationAlwaysIsGranted
            .then((permission) {
              if(permission == MimosaLocationPermissionStatus.alwaysGranted) {
                recCheckPermission(otherPermissions);
              }
              else {
                widget.onNext();
              }
          }
        )
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Icon(FontAwesomeIcons.seedling, size: 150, color: Theme.of(context).primaryColor,),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
            child: Text(
              AppLocalizations.of(context)!.welcome,
              style: Theme
                .of(context)
                .textTheme
                .headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.checking_auth,
                style: Theme.of(context).textTheme.bodyLarge!,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 40),
            child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
          )
        ]);

  }
}