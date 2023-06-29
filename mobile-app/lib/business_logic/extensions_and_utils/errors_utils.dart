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
import 'package:mimosa/business_logic/models/errors/mimosa_errors.dart';

class JsonToModelMappingError extends MimosaError {
  final String model;
  JsonToModelMappingError(this.model);

  @override
  String toString() {
    return 'Errore nel format dei dati: $model';
  }

  @override
  Future<String> formatError() async {
    return toString();
  }
}

Validation<T> tryMapJsonToModel<T>(T Function() mapJsonToModel) {
  try {
    return Valid(mapJsonToModel());
  }
  catch(e) {
    if(e is Error) {
      return Fail.withError(e).toInvalid();
    }
    else if(e is Exception) {
      return Fail.withException(e).toInvalid();
    }

    return Fail.withError(Error()).toInvalid();
  }
}

void rethrowJsonToModelMappingError (dynamic e, String model) {
  if(e is JsonToModelMappingError) {
    throw JsonToModelMappingError('$model -> ${e.model}');
  }

  throw (JsonToModelMappingError(model));
}