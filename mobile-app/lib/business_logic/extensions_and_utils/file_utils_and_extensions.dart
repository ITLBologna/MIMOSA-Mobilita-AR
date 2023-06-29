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
import 'dart:typed_data';
import 'package:mimosa/business_logic/extensions_and_utils/future_extensions.dart';
import 'package:path/path.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:path_provider/path_provider.dart';

extension FileValidationExt on File {
  Future<Validation<Uint8List>> readBytes() {
    return readAsBytes().tryCatch();
  }
}

extension StringPathExts on String {
  String joinPath(String path) =>
      path.isEmpty ? this : join(this, path);

  String addExtension(String extension) =>
      extension.startsWith('.') ? '${this}$extension' : '${this}.$extension';

  Future<bool> fileExists({String? inInnerPath}) =>
      getLocalPath(innerPath: inInnerPath)
          .joinPath(this)
          .then((value) => File(value).exists());

  Future deleteFile({String? fromInnerPath}) => getLocalPath(innerPath: fromInnerPath)
      .joinPath(this)
      .then((value) => File(value).delete().tryCatch());

  Future createDir() => createDirectory(this);
}

extension FutureStringPathExts on Future<String> {
  Future<String> joinPath(String path) => then((value) => value.joinPath(path));
  Future createDir() => then((value) => createDirectory(value));
}

Future<String> getLocalPath({String? innerPath}) {
  if(Platform.isAndroid || Platform.isIOS) {
    return getApplicationDocumentsDirectory()
        .then((value) => value.path.joinPath(innerPath ?? '')
    );
  }

  return toFuture(innerPath ?? './');
}

Future createDirectory(String path) {
  final dir = Directory(path);
  return dir.exists().then((exists) {
    if(!exists) {
      return dir.create(recursive: true);
    }
  });

}