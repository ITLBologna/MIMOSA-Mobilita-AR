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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/user_access_controller.dart';
import 'package:mimosa/ui/library_widgets/future_builder_enhanced.dart';
import 'package:mimosa/ui/widgets/back_button_app_bar.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final iConfigService = serviceLocator.get<IConfigurationService>();
  bool _isLoading = true;
  final userAccessController = Get.find<UserAccessController>();

  @override
  Widget build(BuildContext context) {
    MatomoTracker.instance.trackScreenWithName(
        widgetName: 'Survey', eventName: 'Open Survey page');

    return Scaffold(
        appBar:
            BackButtonAppBar(title: Text(AppLocalizations.of(context)!.survey)),
        body: FutureBuilderEnhanced(
            future: userAccessController.userAccessResponse,
            onDataLoaded: (data) {
              Uri? parsedUri = Uri.parse(
                  '${const String.fromEnvironment('SURVEY_ADDRESS')}/${data!.showablePoll}/${userAccessController.sUserId}');

              return data.showablePoll != null
                  ? Stack(
                      children: [
                        InAppWebView(
                          initialUrlRequest: URLRequest(url: parsedUri),
                          initialOptions: InAppWebViewGroupOptions(
                              crossPlatform: InAppWebViewOptions(
                                  clearCache: true, cacheEnabled: false)),
                          onLoadStop: (__, _) {
                            debugPrint('Stop loading');
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          onLoadError: (controller, uri, errorCode, message) =>
                              debugPrint(
                                  'Si è verificato un errore $errorCode: $message'),
                          onLoadHttpError: (controller, uri, errorCode,
                                  message) =>
                              debugPrint(
                                  'Si è verificato un errore $errorCode: $message'),
                        ),
                        if (_isLoading)
                          Container(
                            color: Colors.white,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.0),
                      child: Row(children: [
                        Expanded(
                            flex: 1,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Text(
                                      "Nessun sondaggio attualmente disponibile",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  )
                                ]))
                      ]),
                    );
            }));
  }
}
