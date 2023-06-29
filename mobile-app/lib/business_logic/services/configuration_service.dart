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
import 'package:flutter/services.dart';
import 'package:mimosa/business_logic/extensions_and_utils/future_extensions.dart';
import 'package:mimosa/business_logic/models/configuration_settings.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ConfigurationService implements IConfigurationService {
  String _versionAndBuild = '';
  String get versionAndBuild => _versionAndBuild;
  static ConfigurationSettings? _settings;

  static Future<ConfigurationSettings> _loadConfigurationSettings (String? configurationType) {
    if (_settings == null)
    {           
      return rootBundle
          .loadString('assets/jsons/configuration_settings.json')
          .then((json) {
            _settings = ConfigurationSettings.fromJson(json, configurationType);
            return _settings!;
          });
    }
    
    return toFuture(_settings!);
  }

  /// Call in main after WidgetsFlutterBinding.ensureInitialized().
  @override
  Future<ConfigurationSettings> loadSettings ({String? configurationType}) => _loadConfigurationSettings(configurationType);

  @override
  ConfigurationSettings get settings => _settings!;

  @override
  Future<Validation<String>> initVersion() {
    _versionAndBuild = '';
    return PackageInfo
        .fromPlatform()
        .then((pi) {
          _versionAndBuild = 'v${pi.version} (${pi.buildNumber})';
          return Valid(_versionAndBuild);
        })
        .tryCatch();
  }
}