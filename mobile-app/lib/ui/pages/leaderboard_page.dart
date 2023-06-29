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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_leaderbord.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/leaderboard_controller.dart';
import 'package:mimosa/ui/library_widgets/alert_dialog.dart';
import 'package:mimosa/ui/library_widgets/controller_driven_widget.dart';
import 'package:mimosa/ui/widgets/back_button_app_bar.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final controller = Get.put(LeaderboardController());

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
        appBar: BackButtonAppBar(
          title: Text(loc.leaderboard),
          actions: [
            IconButton(
                onPressed: () {
                  final localStorage = serviceLocator.get<ILocalStorage>();
                  localStorage.getUserId().fold((failures) {
                    showAlertDialogEx(context,
                        progressIndicatorTag: 'user id',
                        title: loc.your_user_id,
                        message: loc.user_id_error);
                  }, (val) {
                    showAlertDialogEx(context,
                        progressIndicatorTag: 'user id',
                        title: loc.your_user_id,
                        message: val);
                  });
                },
                icon: const Icon(
                  Icons.info,
                  color: Colors.black54,
                ))
          ],
        ),
        body: ControllerDrivenWidget<LeaderboardController, MimosaLeaderboard,
            NoValue>(
          controller: controller,
          getBody: (ranks) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                          child: AutoSizeText(
                        loc.rank,
                        style: theme.textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      )),
                      Expanded(
                          child: AutoSizeText(
                        loc.score,
                        minFontSize: 8,
                        style: theme.textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ))
                    ],
                  ),
                ),
                Container(
                  height: 3,
                  color: theme.primaryColor,
                ),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ranks.userRank == null
                          ? (ranks.mimosaRanks.length)
                          : (ranks.mimosaRanks.length +
                              (ranks.mimosaRanks
                                          .elementAt(
                                              ranks.mimosaRanks.length - 1)
                                          .rank <
                                      ranks.userRank!.rank
                                  ? 1
                                  : 0)),
                      itemBuilder: (context, index) {
                        String rank = ranks.userRank == null
                            ? ranks.mimosaRanks[index].rank.toString()
                            : (index < ranks.mimosaRanks.length
                                ? ranks.mimosaRanks[index].rank.toString()
                                : ranks.userRank!.rank.toString());
                        String points = ranks.userRank == null
                            ? ranks.mimosaRanks[index].points.toString()
                            : (index < ranks.mimosaRanks.length
                                ? ranks.mimosaRanks[index].points.toString()
                                : ranks.userRank!.points.toString());
                        bool selected = ranks.userRank == null
                            ? false
                            : (index < ranks.mimosaRanks.length
                                ? (ranks.mimosaRanks[index].rank ==
                                    ranks.userRank!.rank)
                                : true);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          color: selected ? theme.primaryColor : Colors.white,
                          child: Row(
                            children: [
                              _ScoreText(rank, isSelected: selected),
                              _ScoreText(points, isSelected: selected)
                            ],
                          ),
                        );
                      }),
                ),
              ],
            );
          },
        ));
  }
}

class _ScoreText extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _ScoreText(this.text, {required this.isSelected, super.key});

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.labelMedium;
    if (isSelected) {
      style = style?.copyWith(fontWeight: FontWeight.bold);
    }

    return Expanded(
      child: Center(
        child: SizedBox(
            width: 50,
            child: AutoSizeText(
              text,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: style,
            )),
      ),
    );
  }
}
