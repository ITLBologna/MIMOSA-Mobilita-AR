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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl_standalone.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_notification_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/permissions_controller.dart';
import 'package:mimosa/controllers/user_access_controller.dart';
import 'package:mimosa/get_page_middleware/access_on_dispose_middleware.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/pages/guide/guide_carousel_page.dart';
import 'package:mimosa/ui/pages/guide/guide_page_arguments.dart';
import 'package:mimosa/ui/pages/home_page.dart';
import 'package:mimosa/ui/pages/init_error_page.dart';
import 'package:mimosa/ui/pages/intro/permissions_checks_carousel_page.dart';
import 'package:mimosa/ui/pages/itineraries_page.dart';
import 'package:mimosa/ui/pages/leaderboard_page.dart';
import 'package:mimosa/ui/pages/playground.dart';
import 'package:mimosa/ui/pages/routes_page/routes_page.dart';
import 'package:mimosa/ui/pages/splash_screen_page.dart';
import 'package:mimosa/ui/pages/suggestions_page.dart';
import 'package:mimosa/ui/pages/survey_page.dart';
import 'package:mimosa/ui/pages/trips_map_page.dart';
import 'package:mimosa/ui/pages/web_guide/web_guide_arguments.dart';
import 'package:mimosa/ui/pages/web_guide/web_guide_page.dart';
import 'package:mimosa/ui/theme/primary_palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();
  var license = await rootBundle.loadString('assets/licenses/OFL.txt');
  LicenseRegistry.addLicense(() => Stream<LicenseEntry>.value(
      LicenseEntryWithLineBreaks(['google_fonts'], license)));

  await setupServiceLocator(configurationType: kDebugMode ? 'debug' : null).then(
      (value) {
    final localStorageService = serviceLocator.get<ILocalStorage>();
    return localStorageService.init();
  }).map((value) {
    final ln = serviceLocator.get<ILocalNotificationService>();
    return ln.initialize();
  }).fold(
      (failures) => runApp(const InitErrorPage(
          errorMessage:
              'Local storage fatal error. Call Mimosa support or reinstall the app.')),
      (val) => runApp(const MyApp()));

  await MatomoTracker.instance.initialize(
      siteId: const int.fromEnvironment('MATOMO_SITE_ID'),
      url: const String.fromEnvironment('MATOMO_URL'));

  serviceLocator.get<ILocalStorage>().getUserId().fold((failures) => {}, (val) {
    MatomoTracker.instance.setVisitorUserId(val);
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String initErrorMessage;

  const MyApp(
      {this.initialRoute = permissionsCarouselRoute,
      this.initErrorMessage = '',
      super.key});

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.montserrat().fontFamily;
    const textColorMedium = Colors.black45;
    final configService = serviceLocator.get<IConfigurationService>();

    Get.put(PermissionsController());
    Get.lazyPut<UserAccessController>(() => UserAccessController());

    return GetMaterialApp(
      title: 'Mimosa',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
      ],
      themeMode: ThemeMode.light,
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: primaryLightPalette,
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: Colors.white,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              )),
          textTheme: TextTheme(
            displayLarge: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            displayMedium: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            displaySmall: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            headlineLarge: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            headlineMedium: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            headlineSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColorMedium, fontFamily: fontFamily, fontSize: 16),
            titleLarge: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColorMedium, fontFamily: fontFamily, fontSize: 18),
            titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColorMedium,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  fontFamily: fontFamily,
                ),
            labelLarge: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            labelMedium: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            labelSmall: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: textColorMedium, fontFamily: fontFamily),
            bodyLarge: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: textColorMedium, fontFamily: fontFamily),
            bodyMedium: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: textColorMedium, fontFamily: fontFamily),
            bodySmall: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: textColorMedium, fontFamily: fontFamily),
          )),
      initialRoute: splashScreenRoute,
      getPages: [
        GetPage(name: playgroundRoute, page: () => const PlaygroundPage()),
        GetPage(name: splashScreenRoute, page: () => const SplashScreenPage()),
        GetPage(
            name: guideCarouselRoute,
            page: () => const GuideCarouselPage(),
            arguments: GuidePageArguments(false)),
        GetPage(
            name: permissionsCarouselRoute,
            page: () => const PermissionsChecksCarouselPage()),
        GetPage(
            name: initErrorRoute,
            page: () => InitErrorPage(
                  errorMessage: initErrorMessage,
                )),
        GetPage(name: homeRoute, page: () => const HomePage(title: 'Mimosa')),
        GetPage(name: routesRoute, page: () => const RoutesPage()),
        GetPage(name: tripsMapPageRoute, page: () => const TripsMapPage()),
        GetPage(name: itinerariesPageRoute, page: () => ItinerariesPage()),
        GetPage(name: itineraryMapRoute, page: () => const TripsMapPage()),
        GetPage(
            name: surveyRoute,
            page: () => const SurveyPage(),
            middlewares: [AccessOnDisposeMiddleware()]),
        GetPage(
          name: suggestionsRoute,
          page: () => const SuggestionsPage(),
          middlewares: [AccessOnDisposeMiddleware()],
        ),
        GetPage(
            name: webGuideRoute,
            page: () => const WebGuidePage(),
            arguments: WebGuideArguments(GuidePage.home)),
        GetPage(name: leaderboardRoute, page: () => const LeaderboardPage()),
      ],
    );
  }
}

class AppInError extends MyApp {
  const AppInError({super.key, super.initialRoute = initErrorRoute});
}
