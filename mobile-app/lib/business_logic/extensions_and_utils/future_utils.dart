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

import 'package:tuple/tuple.dart';

Future<Tuple2<T1, T2>> waitConcurrently<T1, T2>(Future<T1> future1,
    Future<T2> future2) async {
  late T1 result1;
  late T2 result2;

  await Future.wait([
    future1.then((value) => result1 = value),
    future2.then((value) => result2 = value)
  ]);

  return Future.value(Tuple2(result1, result2));
}