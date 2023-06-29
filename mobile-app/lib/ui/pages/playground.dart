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
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({Key? key}) : super(key: key);

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final localStorage = serviceLocator.get<ILocalStorage>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: localStorage.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: Text(
                    'User Id: ${snapshot.data?.fold((failures) => 'fail', (val) => val)}'),
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: Text('No data'),
              ),
            );
          }
        });
    /*return Scaffold(
      body: Center(
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100),
            child: Container(
              color: Colors.yellow,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 5,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        flex: 1,
                        child: ExampleText(color: Colors.red, text: '')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        flex: 1,
                        child: ExampleText(color: Colors.blue, text: '')),
                  ],
                )
              ]),
            ),
          ),
        ),
      ),
    );*/
  }
}

class ExampleText extends StatelessWidget {
  final Color color;
  final String text;

  const ExampleText({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: color, child: Text(text));
  }
}
