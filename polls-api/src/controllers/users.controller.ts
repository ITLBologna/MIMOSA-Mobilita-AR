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
 * Mimosa API
 *
 *
 * Contact: info@bitapp.it
 */

import { Request, Response } from "express";
import { get_user, post_user, show_poll, update_user_consents } from "../services/users.service.js";
import { gamificationEnabled, leaderboardEnabled } from "../index.js";

export async function access_user(req: Request, res: Response) {
    const {user_id, gamification_consent, suggestions_consent, survey_consent} = req.body;

    let user_item = await get_user(user_id);
    let register_date = user_item.Item?.created_at;
    let user;

    if (user_item.Item == undefined) {
        register_date = Date.now();
        //registra l'utente all'interno del db
        user = await post_user(user_id, gamification_consent, suggestions_consent, survey_consent);

    } else if (user_item.Item.gamification_consent != gamification_consent || user_item.Item.suggestions_consent != suggestions_consent || user_item.Item.survey_consent != survey_consent ){
        await update_user_consents(user_id, gamification_consent, suggestions_consent, survey_consent);    
    }

    //funzione per confrontare (data di registrazione + time to show(sondaggio)> data di oggi ? cicla sul prossimo sondaggio : l'utente ha risposto al sondaggio ? cicla sul prossimo sondaggio : manda poll_id )
    let poll = await show_poll(register_date, user_id)

    res.send({data: {showable_poll: poll && survey_consent ? poll : null, gamification_enabled: gamificationEnabled && gamification_consent ? true : false, leaderboard_enabled: leaderboardEnabled}});

}

export async function suggestions(req: Request, res: Response){
  const user_id = req.params.user_id;
  let user = await get_user(user_id);

  if(user.Item){
      res.send({data: {code : user.Item.suggestions_consent ? 'result_not_available' : 'consent_not_given'}})
  } else { 
      res.sendStatus(404);
  }
}

