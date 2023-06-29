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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/ui/pages/web_guide/web_guide_arguments.dart';
import 'package:mimosa/ui/widgets/back_button_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebGuidePage extends StatefulWidget {
  const WebGuidePage({Key? key}) : super(key: key);

  @override
  State<WebGuidePage> createState() => _WebGuidePageState();
}

class _WebGuidePageState extends State<WebGuidePage> {
  String guideUrl = const String.fromEnvironment('GUIDE_URL');

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as WebGuideArguments;

    MatomoTracker.instance.trackScreenWithName(
        widgetName: 'Web Guide',
        eventName: 'Open Web guide with sub route: ${args.guidePage.subRoute}');
    List<String> urlSegments = [guideUrl];
    if (args.guidePage.subRoute != '') {
      urlSegments.add(args.guidePage.subRoute);
    }
    Uri? parsedUri = Uri.parse('${urlSegments.join('/')}?lang=${AppLocalizations.of(context)!.localeName}');

    debugPrint('Parsed URI: ${parsedUri.toString()}');

    return Scaffold(
        appBar:
            BackButtonAppBar(title: Text(AppLocalizations.of(context)!.web_guide)),
        body: Stack(
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
                  debugPrint('Si è verificato un errore $errorCode: $message'),
              onLoadHttpError: (controller, uri, errorCode, message) =>
                  debugPrint('Si è verificato un errore $errorCode: $message'),
            ),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ));
  }
}
