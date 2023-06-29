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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/library_widgets/future_builder_enhanced.dart';
import 'package:mimosa/ui/pages/intro/permissions_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mimosa/ui/pages/intro/welcome_page.dart';
import 'package:mimosa/ui/pages/intro/locations_permissions_page.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsChecksCarouselPage extends StatefulWidget {
  const PermissionsChecksCarouselPage({Key? key}) : super(key: key);

  @override
  State<PermissionsChecksCarouselPage> createState() => _PermissionsChecksCarouselPageState();
}

class _PermissionsChecksCarouselPageState extends State<PermissionsChecksCarouselPage> with TraceableClientMixin {
  final PageController pageController = PageController();
  late final List<Widget Function()> tutorialPages;
  final carouselInitializationCompleter = Completer();
  late final Future carouselInitializedFuture;

  void _gotoNextPage() {
    pageController
        .nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut);
  }

  void _jumpToPage(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    carouselInitializedFuture = carouselInitializationCompleter.future;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var pages = <Widget Function()>[
            () => WelcomePage(onNext: _gotoNextPage, jumpTo: _jumpToPage,),
            () => LocationsPermissionsPage(onNext: _gotoNextPage),
            () => PermissionsPage(
          onNext: _gotoNextPage,
          permission: Permission.camera,
          deniedMessage: AppLocalizations.of(context)!.camera_access_denied,
          permanentlyDeniedMessage: AppLocalizations.of(context)!.camera_access_permanently_denied,
          iconData: Icons.camera_alt,
        ),
            () => PermissionsPage(
          onNext: () => Get.offAndToNamed(homeRoute),
          permission: Platform.isAndroid ? Permission.activityRecognition : Permission.sensors,
          deniedMessage: AppLocalizations.of(context)!.activity_access_denied,
          permanentlyDeniedMessage: AppLocalizations.of(context)!.activity_access_permanently_denied,
          iconData: Icons.directions_bike,
        )
      ];

      tutorialPages = pages;
      carouselInitializationCompleter.complete();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderEnhanced(
      future: carouselInitializedFuture,
      onDataLoaded: (_) {
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: SafeArea(
            top: true,
            child: Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                          itemCount: tutorialPages.length,
                          physics: const NeverScrollableScrollPhysics(),
                          pageSnapping: true,
                          controller: pageController,
                          itemBuilder: (context, pagePosition){
                            return tutorialPages[pagePosition]();
                          }),
                    )
                  ],
                )

            ),
          )
        );
      }
    );
  }

  @override
  String get traceName => 'PermissionsChecksCarousel';

  @override
  String get traceTitle => 'PermissionsChecksCarousel';
}
