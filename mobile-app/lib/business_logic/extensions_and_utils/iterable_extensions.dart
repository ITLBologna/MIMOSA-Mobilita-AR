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

import 'dart:math';

extension IterableExt<T> on Iterable<T> {
  T? getFirst({T Function()? orElse}) {
    if(isEmpty) {
      if(orElse != null) {
        return orElse();
      }
      else {
        return null;
      }
    }
    else {
      return first;
    }
  }

  T? getLast({T Function()? orElse}) {
    if(isEmpty) {
      if(orElse != null) {
        return orElse();
      }
      else {
        return null;
      }
    }
    else {
      return last;
    }
  }

  T? getFirstWhere(bool Function(T) test, {T Function()? orElse}) {
    if(isEmpty) {
      if(orElse != null) {
        return orElse();
      }
      else {
        return null;
      }
    }
    else {
      for (T element in this) {
        if (test(element)) return element;
      }

      if (orElse != null) {
        return orElse();
      }

      return null;
    }
  }

  int getIndexWhere(bool Function(T) test) {
    if(isEmpty) {
      return -1;
    }
    else {
      for (int i = 0; i < length; i ++) {
        if (test(elementAt(i))) return i;
      }

      return -1;
    }
  }

  T? getLastWhere(bool Function(T) test, {T Function()? orElse}) {
    if(isEmpty) {
      if(orElse != null) {
        return orElse();
      }
      else {
        return null;
      }
    }
    else {
      for (var i = length - 1; i >= 0; i --) {
        if (test(elementAt(i))) return elementAt(i);
      }

      if (orElse != null) {
        return orElse();
      }

      return null;
    }
  }


  Iterable<T> distinctBy(Object Function(T e) getCompareValue) {
    var result = <T>[];
    forEach((element) {
      if (!result.any((x) => getCompareValue(x) == getCompareValue(element))) {
        result.add(element);
      }
    });

    return result;
  }

  Iterable<T> getLastEntries(int nEntries) {
    var maxEntries = min(length, nEntries);
    var nSkip = length - maxEntries;
    return skip(nSkip);
  }
}

extension EnumMatch<T extends Enum> on Iterable<T> {
  T? getMatchOnValue(dynamic match, {T Function()? orElse}) {
    return
      getFirstWhere((e) => e.name.toLowerCase() == match?.toString().toLowerCase())
          ?? orElse?.call();
  }
}