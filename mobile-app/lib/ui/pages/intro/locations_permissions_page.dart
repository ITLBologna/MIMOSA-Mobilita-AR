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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formatted_text/formatted_text.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/ui/library_widgets/future_builder_enhanced.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocationsPermissionsPage extends StatefulWidget {
  final void Function() onNext;
  const LocationsPermissionsPage({super.key, required this.onNext});

  @override
  State<LocationsPermissionsPage> createState() => _LocationsPermissionsPageState();
}

class _LocationsPermissionsPageState extends State<LocationsPermissionsPage> with WidgetsBindingObserver {
  late Future<MimosaLocationPermissionStatus> locationPermissionsFuture;
  final _locationService = serviceLocator.get<ILocationService>();
  bool _firstTimeWhenInUseDenied = true;

  @override
  void initState() {
    locationPermissionsFuture = _locationService.checkLocationPermissions();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _getLocationServicesDisabledMessage(BuildContext context) {
    return Platform.isIOS
        ? AppLocalizations.of(context)!.location_services_disabled_ios
        : AppLocalizations.of(context)!.location_services_disabled;
  }

  String _getLocationPermanentlyDeniedMessage(BuildContext context) {
    return Platform.isIOS
      ? AppLocalizations.of(context)!.location_access_permanently_denied_ios
      : AppLocalizations.of(context)!.location_access_permanently_denied;
  }

  String _getLocationDeniedMessage(BuildContext context) {
    return Platform.isIOS
        ? AppLocalizations.of(context)!.location_access_denied_ios
        : AppLocalizations.of(context)!.location_access_denied;
  }

  Future<bool> _requestLocationAlways() {
    return _locationService
        .checkLocationAlwaysPermissionStatus()
        .map((permission) {
          if(permission == MimosaLocationPermissionStatus.granted) {
            widget.onNext();
            return true;
          }
          else {
            return false;
          }
        })
    .fold(
      (failures) => false,
      (val) => val);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      locationPermissionsFuture = _locationService.checkLocationPermissions();
      locationPermissionsFuture
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
            locationPermissionsFuture = _locationService.checkLocationPermissions();
          }),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 80.0, bottom: 30),
                  child: Icon(FontAwesomeIcons.compass, size: 150, color: Colors.black26,),
                ),
                FutureBuilderEnhanced(
                    future: locationPermissionsFuture,
                    onDataLoaded: (status) {
                      if(status == MimosaLocationPermissionStatus.alwaysGranted) {
                          WidgetsBinding
                              .instance
                              .addPostFrameCallback((timeStamp)
                                  => widget.onNext());
                          return const CircularProgressIndicator();
                      }
                      else if(status == MimosaLocationPermissionStatus.serviceDisabled) {
                        return Column(
                          children: [
                            FormattedText(
                              _getLocationServicesDisabledMessage(context),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ],
                        );
                      }
                      else {
                        if(status == MimosaLocationPermissionStatus.whenInUseDenied && _firstTimeWhenInUseDenied) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: FormattedText(
                                  _getLocationDeniedMessage(context),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      _locationService
                                          .checkLocationWhenInUsePermissionStatus()
                                          .map((permission) {
                                        if(permission == MimosaLocationPermissionStatus.whenInUseGranted) {
                                          _requestLocationAlways()
                                              .then((value) {
                                            if(!value) {
                                              setState(() {
                                                _firstTimeWhenInUseDenied = false;
                                                locationPermissionsFuture = _locationService.checkLocationPermissions();
                                              });
                                            }
                                          });
                                        }
                                        else if(permission == MimosaLocationPermissionStatus.permanentlyDenied) {
                                          setState(() {
                                            _firstTimeWhenInUseDenied = false;
                                            locationPermissionsFuture = _locationService.checkLocationPermissions();
                                          });
                                        }
                                      });
                                    },
                                    child: Text(AppLocalizations.of(context)!.allow)
                                ),
                              )
                            ],
                          );
                        }
                        else {
                          WidgetsBinding.instance.addObserver(this);
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: FormattedText(
                                  _getLocationPermanentlyDeniedMessage(context),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      debugPrint('Open settings');
                                      openAppSettings();
                                    },
                                    child: Text(AppLocalizations.of(context)!.settings)
                                ),
                              )
                            ],
                          );
                        }
                      }
                    }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
