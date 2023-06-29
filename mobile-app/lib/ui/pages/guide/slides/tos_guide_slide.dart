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
import 'package:mimosa/ui/pages/guide/slides/i_guide_slide.dart';
import 'package:mimosa/ui/pages/guide/slides/webview_guide_page.dart';

class TosGuideSlide extends IGuideSlide {
  final bool accepted;
  final Function() onAgreeClick;

  bool _isLoading = true;

  TosGuideSlide({required this.onAgreeClick, this.accepted = false});

  @override
  Widget page() {
    return WebViewGuidePage(
      requireInteractionBeforeNextPage: true,
      showIfNotFirstTime: false,
      pageName: 'tos',
      tile: (context) => Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(
                          '${const String.fromEnvironment('TOS_URL')}?lang=${AppLocalizations.of(context)!.localeName}')),
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                          clearCache: true,
                          cacheEnabled: false,
                          transparentBackground: true)),
                  onLoadStop: (__, _) {
                    debugPrint('Stop loading');
                    _isLoading = false;
                  },
                  onLoadError: (controller, uri, errorCode, message) =>
                      debugPrint(
                          'Si è verificato un errore $errorCode: $message'),
                  onLoadHttpError: (controller, uri, errorCode, message) =>
                      debugPrint(
                          'Si è verificato un errore $errorCode: $message'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () => onAgreeClick(),
              child: Text(accepted
                  ? AppLocalizations.of(context)!.accepted_button
                  : AppLocalizations.of(context)!.accept_button),
            ),
          )
        ],
      ),
    );
  }
}
